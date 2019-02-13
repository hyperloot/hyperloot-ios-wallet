//
//  TokenInfoViewModel.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

class TokenInfoViewModel {
    
    struct Presentation {
        let itemImageURL: String
        let itemName: String
        let itemShortDescription: String
        let itemPrice: NSAttributedString
        let itemDescription: String
    }
    
    let token: HyperlootToken
    let attributes: HyperlootToken.Attributes
    
    var presentation: Presentation {
        return Presentation(itemImageURL: attributes.imageURL,
                            itemName: attributes.name,
                            itemShortDescription: attributes.description,
                            itemPrice: BalanceFormatter.format(balance: "$10",
                                                               fontHeight: 20.0,
                                                               change: .up(value: "2.0"),
                                                               changeFontHeight: 15.0),
                            itemDescription: attributes.description)
    }
    
    required init(token: HyperlootToken, attributes: HyperlootToken.Attributes) {
        self.token = token
        self.attributes = attributes
    }
    
}
