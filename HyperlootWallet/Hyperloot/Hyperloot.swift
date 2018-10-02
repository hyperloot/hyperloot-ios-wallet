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
    
    func createWallet(email: String, password: String, completion: @escaping (_ address: String?, _ mnemonicPhraseWords: [String]?, _ error: Error?) -> Void) {
        walletManager.createWallet(email: email, password: password) { [weak self] (info, error) in
            
            if let info = info {
                self?.userManager.createUser(withEmail: email, walletAddress: info.address)
            }
            
            completion(info?.address.eip55String, info?.mnemonicPhraseWords, error)
        }
    }
    
    
    func importWallet() {
        
    }
}
