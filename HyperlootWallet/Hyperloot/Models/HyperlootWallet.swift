//
//  HyperlootWallet.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import TrustCore
import TrustKeystore

struct HyperlootWallet {
    
    enum WalletType {
        case privateKey(Account)
        case hd(Account)
    }
    
    let type: WalletType
    
    var address: Address {
        switch type {
        case .privateKey(let account):
            return account.address
        case .hd(let account):
            return account.address
        }
    }
}

extension HyperlootWallet {
    var addressString: String {
        return address.description
    }
}
