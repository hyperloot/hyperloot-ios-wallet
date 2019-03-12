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
        
    func hasTokenId() -> Bool {
        if case .erc721(tokenId: let tokenId, totalCount: _, attributes: _) = self.type {
            return tokenId != HyperlootToken.Constants.noTokenId
        }
        
        return false
    }
}
