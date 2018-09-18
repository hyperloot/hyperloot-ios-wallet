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

}

extension Hyperloot: HyperlootTokensManaging {
    
    func getTokens() {
        
    }
    
    func getBalance() {
        
    }
}

extension Hyperloot: HyperlootWalletManaging {
    
    func createWallet() {
        
    }
    
    func importWallet() {
        
    }
}
