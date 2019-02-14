//
//  HyperlootToken+Helpers.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

extension HyperlootToken {
    func isERC721() -> Bool {
        var isERC721: Bool = false
        if case .erc721 = type {
            isERC721 = true
        }
        
        return isERC721
    }
}
