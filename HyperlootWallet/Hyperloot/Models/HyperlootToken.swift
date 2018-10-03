//
//  HyperlootERC20Token.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 10/1/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import TrustCore

struct HyperlootToken {
    
    struct Attributes {
        let description: String
        let name: String
        let imageURL: String
    }
    
    enum TokenType {
        case erc20
        case erc721(tokenId: String, attributes: Attributes)
    }
    
    let cataloged: Bool
    let contractAddress: String
    let name: String
    let symbol: String
    let decimals: Int
    let totalSupply: Int
    let type: TokenType
}
