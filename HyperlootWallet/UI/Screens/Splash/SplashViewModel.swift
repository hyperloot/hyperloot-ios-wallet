//
//  SplashViewModel.swift
//  HyperlootWallet
//
//  Created by valery_vaskabovich on 9/27/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

class SplashViewModel {
    
    func hasWallets() -> Bool {
        return Hyperloot.shared.currentWallet() != nil
    }
    
}