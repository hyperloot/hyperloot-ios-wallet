//
//  WalletKeyStore.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 9/13/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import Result
import TrustCore
import TrustKeystore
import KeychainSwift
import CryptoSwift

class WalletKeyStore {
    
    enum KeyStoreError: Error {
        case failedToDeleteAccount
        case failedToDecryptKey
        case failedToImport(Error)
        case duplicateAccount
        case failedToSignTransaction
        case failedToUpdatePassword
        case failedToCreateWallet
        case failedToImportPrivateKey
        case failedToParseJSON
        case accountNotFound
        case failedToSignMessage
        case failedToSignTypedMessage
        case failedToExportPrivateKey
        case invalidMnemonicPhrase
    }
    
    enum ImportType {
        case keystore(string: String, password: String)
        case privateKey(privateKey: String)
        case mnemonic(words: [String], password: String)
    }
    
    struct Constants {
        static let keychainKeyPrefix = "hyperl"
        static let keyStoreSubfolder = "/keystore"
    }
    
    private let keychain: KeychainSwift
    let keyStore: KeyStore
    private let defaultKeychainAccess: KeychainSwiftAccessOptions = .accessibleWhenUnlockedThisDeviceOnly
    
    public init(keychain: KeychainSwift = KeychainSwift(keyPrefix: Constants.keychainKeyPrefix),
                keyStoreSubfolder: String = Constants.keyStoreSubfolder) {
        self.keychain = keychain
        self.keychain.synchronizable = false
        
        let userDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let keyStoreDir = URL(fileURLWithPath: userDirectory + keyStoreSubfolder)
        self.keyStore = try! KeyStore(keyDirectory: keyStoreDir)
    }
    
    @discardableResult
    func setPassword(_ password: String, for account: Account) -> Bool {
        return keychain.set(password, forKey: keychainKey(for: account), withAccess: defaultKeychainAccess)
    }

    func getPassword(for account: Account) -> String? {
        return keychain.get(keychainKey(for: account))
    }
    
    private var wallets: [HyperlootWallet] {
        return [keyStore.accounts.map {
            switch $0.type {
            case .encryptedKey: return HyperlootWallet(type: .privateKey($0))
            case .hierarchicalDeterministicWallet: return HyperlootWallet(type: .hd($0))
            }
            }].flatMap { $0 }
    }
    
    public func wallet(byAddress address: Address) -> HyperlootWallet? {
        return wallets.filter { $0.address.description == address.description }.first
    }
    
    func createAccount(with password: String, completion: @escaping (Result<Account, KeyStoreError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let account = self.createAccount(password: password)
            DispatchQueue.main.async {
                completion(.success(account))
            }
        }
    }
    
    func importWallet(type: ImportType, walletPassword: String, completion: @escaping (Result<HyperlootWallet, KeyStoreError>) -> Void) {
        switch type {
        case .keystore(let string, let password):
            importKeystore(value: string, password: password, newPassword: walletPassword) { result in
                switch result {
                case .success(let account):
                    completion(.success(HyperlootWallet(type: .privateKey(account))))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        case .privateKey(let privateKey):
            keystore(for: privateKey, password: walletPassword) { result in
                switch result {
                case .success(let value):
                    self.importKeystore(value: value, password: walletPassword, newPassword: walletPassword) { result in
                        switch result {
                        case .success(let account):
                            completion(.success(HyperlootWallet(type: .privateKey(account))))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        case .mnemonic(let words, let passphrase):
            let string = words.map { String($0) }.joined(separator: " ")
            if !Mnemonic.isValid(string) {
                return completion(.failure(.invalidMnemonicPhrase))
            }
            do {
                let account = try keyStore.import(mnemonic: string, passphrase: passphrase, encryptPassword: walletPassword)
                setPassword(walletPassword, for: account)
                completion(.success(HyperlootWallet(type: .hd(account))))
            } catch {
                return completion(.failure(.duplicateAccount))
            }
        }
    }
    
    // MARK: - KeyStore - operations with private keys, phrases, etc.
    
    func keystore(for privateKey: String, password: String, completion: @escaping (Result<String, KeyStoreError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let keystore = self.convertPrivateKeyToKeystoreFile(privateKey: privateKey, passphrase: password)
            DispatchQueue.main.async {
                switch keystore {
                case .success(let result):
                    completion(.success(result.toJSONString() ?? ""))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func importKeystore(value: String, password: String, newPassword: String, completion: @escaping (Result<Account, KeyStoreError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = self.importKeystore(value: value, password: password, newPassword: newPassword)
            DispatchQueue.main.async {
                switch result {
                case .success(let account):
                    completion(.success(account))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func createAccount(password: String) -> Account {
        let account = try! keyStore.createAccount(password: password, type: .hierarchicalDeterministicWallet)
        let _ = setPassword(password, for: account)
        return account
    }
    
    func importKeystore(value: String, password: String, newPassword: String) -> Result<Account, KeyStoreError> {
        guard let data = value.data(using: .utf8) else {
            return (.failure(.failedToParseJSON))
        }
        
        do {
            let account = try keyStore.import(json: data, password: password, newPassword: newPassword)
            setPassword(newPassword, for: account)
            return .success(account)
        } catch {
            if case KeyStore.Error.accountAlreadyExists = error {
                return .failure(.duplicateAccount)
            } else {
                return .failure(.failedToImport(error))
            }
        }
    }
    
    func export(account: Account, password: String, newPassword: String) -> Result<String, KeyStoreError> {
        let result = self.exportData(account: account, password: password, newPassword: newPassword)
        switch result {
        case .success(let data):
            let string = String(data: data, encoding: .utf8) ?? ""
            return .success(string)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func export(account: Account, password: String, newPassword: String, completion: @escaping (Result<String, KeyStoreError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = self.export(account: account, password: password, newPassword: newPassword)
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    func exportData(account: Account, password: String, newPassword: String) -> Result<Data, KeyStoreError> {
        guard let account = getAccount(for: account.address) else {
            return .failure(.accountNotFound)
        }
        do {
            let data = try keyStore.export(account: account, password: password, newPassword: newPassword)
            return (.success(data))
        } catch {
            return (.failure(.failedToDecryptKey))
        }
    }
    
    func exportPrivateKey(account: Account, completion: @escaping (Result<Data, KeyStoreError>) -> Void) {
        guard let password = getPassword(for: account) else {
            return completion(.failure(.accountNotFound))
        }
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let privateKey = try self.keyStore.exportPrivateKey(account: account, password: password)
                DispatchQueue.main.async {
                    completion(.success(privateKey))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.failedToDecryptKey))
                }
            }
        }
    }
    
    func exportMnemonic(account: Account, completion: @escaping (Result<[String], KeyStoreError>) -> Void) {
        guard let password = getPassword(for: account) else {
            return completion(.failure(.accountNotFound))
        }
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let mnemonic = try self.keyStore.exportMnemonic(account: account, password: password)
                let words = mnemonic.components(separatedBy: " ")
                DispatchQueue.main.async {
                    completion(.success(words))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.accountNotFound))
                }
            }
        }
    }
    
    func delete(wallet: HyperlootWallet) -> Result<Void, KeyStoreError> {
        switch wallet.type {
        case .privateKey(let account), .hd(let account):
            guard let password = getPassword(for: account) else {
                return .failure(.failedToDeleteAccount)
            }
            
            do {
                try keyStore.delete(account: account, password: password)
                return .success(())
            } catch {
                return .failure(.failedToDeleteAccount)
            }
        }
    }
    
    func delete(wallet: HyperlootWallet, completion: @escaping (Result<Void, KeyStoreError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = self.delete(wallet: wallet)
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    func updateAccount(account: Account, password: String, newPassword: String) -> Result<Void, KeyStoreError> {
        guard let account = getAccount(for: account.address) else {
            return .failure(.accountNotFound)
        }
        
        do {
            try keyStore.update(account: account, password: password, newPassword: newPassword)
            return .success(())
        } catch {
            return .failure(.failedToUpdatePassword)
        }
    }
        
    func keychainKey(for account: Account) -> String {
        switch account.type {
        case .encryptedKey:
            return account.address.description.lowercased()
        case .hierarchicalDeterministicWallet:
            return "hd-wallet-" + account.address.description
        }
    }
    
    func getAccount(for address: Address) -> Account? {
        return keyStore.account(for: address)
    }
    
    func convertPrivateKeyToKeystoreFile(privateKey: String, passphrase: String) -> Result<[String: Any], KeyStoreError> {
        guard let data = Data(hexString: privateKey) else {
            return .failure(.failedToImportPrivateKey)
        }
        do {
            let key = try KeystoreKey(password: passphrase, key: data)
            let data = try JSONEncoder().encode(key)
            let dict = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            return .success(dict)
        } catch {
            return .failure(.failedToImportPrivateKey)
        }
    }
}
