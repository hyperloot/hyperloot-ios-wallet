//
//  SplashViewModel.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

class SplashViewModel {
    
    func hasWallets() -> Bool {
        return Hyperloot.shared.currentWallet() != nil
    }
    
}
