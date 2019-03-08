//
//  WalletAsset.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation

class WalletAsset {
    
    enum AssetType {
        case currency
        case gameAsset
    }
    
    typealias AssetId = String
    
    let token: HyperlootToken
    let price: HyperlootTokenPrice?
    
    required init(token: HyperlootToken, price: HyperlootTokenPrice?) {
        self.token = token
        self.price = price
    }
    
    var assetId: AssetId {
        switch value {
        case .erc20, .ether:
            return token.contractAddress
        case .erc721(tokenId: let tokenId, totalCount: _, attributes: _):
            return "\(token.contractAddress)-\(tokenId)"
        }
    }
    
    var value: HyperlootToken.TokenType {
        return token.type
    }
    
    var assetType: AssetType {
        switch value {
        case .erc20, .ether:
            return (price != nil) ? .currency : .gameAsset
        case .erc721:
            return .gameAsset
        }
    }
    
    var totalPrice: Double {
        let numberOfTokens: Double
        switch value {
        case .erc20(amount: let amount):
            numberOfTokens = Double(amount) ?? 0
        case .ether(amount: let amount):
            numberOfTokens = Double(amount) ?? 0
        case .erc721:
            numberOfTokens = 1.0
        }
        
        let pricePerOne = price?.price ?? 0.0
        return numberOfTokens * pricePerOne
    }
}
