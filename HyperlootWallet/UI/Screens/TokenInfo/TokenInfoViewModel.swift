//
//  TokenInfoViewModel.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

class TokenInfoViewModel {
    
    struct Presentation {
        let itemImageURL: String?
        let itemName: String
        let itemShortDescription: String?
        let itemPrice: String
        let itemDescription: String?
    }
    
    let asset: WalletAsset
    
    var attributes: HyperlootToken.Attributes? {
        guard case .erc721(tokenId: _, totalCount: _, attributes: let attributes) = asset.value else {
            return nil
        }
        
        return attributes
    }
    
    var presentation: Presentation {
        return Presentation(itemImageURL: attributes?.imageURL,
                            itemName: attributes?.name ?? asset.token.name,
                            itemShortDescription: attributes?.shortDescription,
                            itemPrice: TokenFormatter.formattedPrice(doubleValue: asset.totalPrice),
                            itemDescription: attributes?.description)
    }
    
    required init(asset: WalletAsset) {
        self.asset = asset
    }
    
}
