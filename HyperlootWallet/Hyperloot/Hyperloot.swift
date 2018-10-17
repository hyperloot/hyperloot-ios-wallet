//
//  Hyperloot.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 9/12/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

class Hyperloot {
    
    fileprivate lazy var walletManager = WalletManager()
    fileprivate lazy var userManager = UserManager()
    
    public static let shared = Hyperloot()
}

extension Hyperloot: HyperlootTokensManaging {
    
    func getTokens() {
        
    }
    
    func getBalance() {
        
    }
}

extension Hyperloot: HyperlootWalletManaging {
    
    func currentWallet() -> HyperlootWallet? {
        guard let user = userManager.user else {
            return nil
        }
        
        return walletManager.wallet(byAddress: user.walletAddress)
    }
    
    func login(email: String, password: String, completion: @escaping (HyperlootUser?, Error?) -> Void) {
        userManager.login(email: email, password: password, completion: completion)
    }
    
    func createWallet(email: String, nickname: String, password: String, completion: @escaping (_ user: HyperlootUser?, _ mnemonicPhraseWords: [String]?, _ error: Error?) -> Void) {
        
        let errorCallback = { (error: Error?) in
            completion(nil, nil, error)
        }
        
        walletManager.createWallet(email: email, password: password) { [weak self] (info, error) in
            
            if let info = info {
                self?.userManager.createUser(withEmail: email, nickname: nickname, walletAddress: info.address) { (user, error) in
                    if error == nil {
                        completion(user, info.mnemonicPhraseWords, nil)
                    } else {
                        errorCallback(error)
                    }
                }
            } else {
                errorCallback(error)
            }
        }
    }
    
    
    func importWallet() {
        
    }
}
