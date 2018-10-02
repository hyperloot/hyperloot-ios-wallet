//
//  WalletManager.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 9/12/18.
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
        
    func createWallet(email: String, password: String, completion: @escaping ((address: Address, mnemonicPhraseWords: [String])?, Error?) -> Void) {
        
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
    
}
