//
//  WalletManager.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import TrustCore
import TrustKeystore

class WalletManager {
    
    fileprivate lazy var walletKeyStore = WalletKeyStore()
    
    func wallet(byAddress address: Address) -> HyperlootWallet? {
        return walletKeyStore.wallet(byAddress: address)
    }
        
    func createWallet(password: String, completion: @escaping ((address: Address, mnemonicPhraseWords: [String])?, Error?) -> Void) {
        
        // Create account
        walletKeyStore.createAccount(with: password) { [weak self] (result) in
            switch result {
            case .success(let account):
                
                // Export mnemonic phrase to display
                self?.walletKeyStore.exportMnemonic(account: account) { result in
                    switch result {
                    case .success(let words):
                        completion((address: account.address, mnemonicPhraseWords: words), nil)
                    case .failure(let error):
                        completion(nil, error)
                    }
                }
                
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    func importWallet(type: HyperlootWalletImportType, password: String, completion: @escaping (HyperlootWallet?, Error?) -> Void) {
        walletKeyStore.importWallet(type: type, walletPassword: password) { (result) in
            switch result {
            case .success(let wallet):
                completion(wallet, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    func exportPrivateKey(wallet: HyperlootWallet, completion: @escaping (String?) -> Void) {
        guard let account = walletKeyStore.getAccount(for: wallet.address) else {
            completion(nil)
            return
        }
        walletKeyStore.exportPrivateKey(account: account) { (result) in
            switch result {
            case .success(let data):
                completion(data.hexString)
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    func exportMnemonicPhrase(wallet: HyperlootWallet, completion: @escaping (String?) -> Void) {
        guard let account = walletKeyStore.getAccount(for: wallet.address) else {
            completion(nil)
            return
        }
        walletKeyStore.exportMnemonic(account: account) { (result) in
            switch result {
            case .success(let words):
                completion(words.joined(separator: " "))
            case .failure(_):
                completion(nil)
            }
        }
    }
}

extension WalletManager: HyperlootTransactionSigning {
    func signTransaction(hash: Data, from address: Address) -> Data {
        return walletKeyStore.signTransaction(hash: hash, from: address)
    }
}
