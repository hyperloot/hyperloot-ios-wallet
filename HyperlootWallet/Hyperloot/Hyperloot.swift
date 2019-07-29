//
//  Hyperloot.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import Result

class Hyperloot {
    
    private let currentConfig: HyperlootConfig = HyperlootConfig.current(for: .testnet)
    
    fileprivate lazy var walletManager = WalletManager()
    
    fileprivate lazy var api = HyperlootAPI(config: currentConfig)
    fileprivate lazy var userManager = UserManager(api: self.api)
    fileprivate lazy var tokenManager = TokenInventoryManager(config: currentConfig)
    
    public static let shared = Hyperloot()
    
    var user: HyperlootUser? {
        return userManager.user
    }
}

extension Hyperloot: HyperlootTokensManaging {
    
    func getPrices(for tokens: [HyperlootToken], cached: Bool, completion: @escaping ([HyperlootTokenPrice]) -> Void) {
        tokenManager.getPrices(tokens: tokens, cached: cached, completion: completion)
    }
    
    func getCachedInventory(completion: @escaping ([HyperlootToken]) -> Void) {
        guard let address = currentWallet()?.addressString else {
            completion([])
            return
        }
        tokenManager.getCachedInventory(address: address, completion: completion)
    }
    
    func updateInventory(completion: @escaping ([HyperlootToken]) -> Void) {
        guard let address = currentWallet()?.addressString else {
            completion([])
            return
        }
        tokenManager.updateInventory(address: address, completion: completion)
    }
    
    func getTransactions(type: HyperlootTransactionType, page: Int, completion: @escaping ([HyperlootTransaction]) -> Void) {
        guard let address = currentWallet()?.addressString else {
            completion([])
            return
        }
        tokenManager.getTransactions(address: address, page: page, transactionType: type, completion: completion)
    }
    
    func send(token: HyperlootToken, to: String, amount: HyperlootSendAmount, completion: @escaping (Result<HyperlootTransaction, HyperlootTransactionSendError>) -> Void) {
        guard let address = currentWallet()?.addressString else {
            completion(.failure(.validationFailed))
            return
        }

        let sendingValue: HyperlootTokenItemSender.SendingValue
        switch token.type {
        case .ether:
            guard case .amount(let etherAmount) = amount,
                let amountInWei = EtherNumberFormatter.full.number(from: etherAmount, units: .ether) else {
                completion(.failure(.validationFailed))
                return
            }
            sendingValue = .ether(amount: amountInWei.description)
        case .erc20:
            guard case .amount(let tokensAmount) = amount,
                let amountInWei = EtherNumberFormatter.full.number(from: tokensAmount, decimals: token.decimals) else {
                completion(.failure(.validationFailed))
                return
            }
            sendingValue = .erc20(amount: amountInWei.description)
        case .erc721(let tokenId, _, _):
            sendingValue = .erc721(tokenId: tokenId)
        }
        tokenManager.send(token: token, from: address, to: to, value: sendingValue, transactionSigner: walletManager, completion: completion)
    }
}

extension Hyperloot: HyperlootWalletManaging {
    
    func currentWallet() -> HyperlootWallet? {
        guard let user = userManager.user else {
            return nil
        }
        
        return walletManager.wallet(byAddress: user.walletAddress)
    }
    
    func canRegister(email: String, completion: @escaping (Bool) -> Void) {
        userManager.canRegister(email: email, completion: completion)
    }
    
    func login(email: String, password: String, completion: @escaping (HyperlootUser?, Error?) -> Void) {
        userManager.login(email: email, password: password, completion: completion)
    }
    
    func signup(email: String, password: String, nickname: String, walletAddress: String, completion: @escaping (_ user: HyperlootUser?, _ error: Error?) -> Void) {
        userManager.createUser(withEmail: email, password: password, nickname: nickname, walletAddress: walletAddress, completion: completion)
    }
    
    func createWallet(password: String, completion: @escaping (_ address: String?, _ mnemonicPhraseWords: [String]?, _ error: Error?) -> Void) {
        walletManager.createWallet(password: password) { (info, error) in
            if let info = info {
                completion(info.address.description, info.mnemonicPhraseWords, nil)
            } else {
                completion(nil, nil, error)
            }
        }
    }
    
    func importWallet(user: HyperlootUser, password: String, importType: HyperlootWalletImportType, completion: @escaping (HyperlootWallet?, Error?) -> Void) {
        walletManager.importWallet(type: importType, password: password, completion: completion)
    }
    
    func findUsers(nickname: String, page: Int = 0, completion: @escaping ([HyperlootUserSuggestion]?, Error?) -> Void) -> Cancelable {
        return api.findUsers(nickname: nickname, page: page, completion: completion)
    }
}

extension Hyperloot: HyperlootWalletExporting {
    
    func exportPrivateKey(user: HyperlootUser, completion: @escaping (String?) -> Void) {
        guard let wallet = walletManager.wallet(byAddress: user.walletAddress) else {
            completion(nil)
            return
        }
        walletManager.exportPrivateKey(wallet: wallet, completion: completion)
    }
    
    func exportMnemonicPhrase(user: HyperlootUser, completion: @escaping (String?) -> Void) {
        guard let wallet = walletManager.wallet(byAddress: user.walletAddress) else {
            completion(nil)
            return
        }
        walletManager.exportMnemonicPhrase(wallet: wallet, completion: completion)
    }
}
