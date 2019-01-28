//
//  Hyperloot.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 9/12/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

class Hyperloot {
    
    private let currentConfig: HyperlootConfig = HyperlootConfig.current(for: .testnet)
    
    fileprivate lazy var api = HyperlootAPI(config: currentConfig)
    fileprivate lazy var walletManager = WalletManager()
    fileprivate lazy var userManager = UserManager(api: self.api)
    fileprivate lazy var tokenManager = TokenInventoryManager(config: currentConfig)
    
    public static let shared = Hyperloot()
    
    var user: HyperlootUser? {
        return userManager.user
    }
}

extension Hyperloot: HyperlootTokensManaging {
    
    func updateInventory(completion: @escaping ([HyperlootToken]) -> Void) {
        guard let address = currentWallet()?.addressString else { return }
        tokenManager.updateInventory(address: address, completion: completion)
    }
    
    func getTransactions(type: HyperlootTransactionType, page: Int, completion: @escaping ([HyperlootTransaction]) -> Void) {
        guard let address = currentWallet()?.addressString else { return }
        tokenManager.getTransactions(address: address, page: page, transactionType: type, completion: completion)
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
    
    func importWallet() {
        
    }
}
