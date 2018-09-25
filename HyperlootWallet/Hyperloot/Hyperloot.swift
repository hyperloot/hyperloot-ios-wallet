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
    fileprivate lazy var walletKeyStore = WalletKeyStore()
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
    
    func createWallet(email: String, password: String, completion: @escaping ([String]?, Error?) -> Void) {
        
        walletKeyStore.createAccount(with: password) { [weak self] (result) in
            switch result {
            case .success(let account):
                
                self?.walletKeyStore.exportMnemonic(account: account) { result in
                    switch result {
                    case .success(let words):
                        self?.userManager.createUser(withEmail: email, walletAddress: account.address)
                        completion(words, nil)
                    case .failure(let error):
                        completion(nil, error)
                    }
                }
                
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    
    func importWallet() {
        
    }
}
