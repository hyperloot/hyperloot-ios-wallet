//
//  HyperlootTokenTransformer.swift
//  HyperlootWallet
//
//  Created by valery_vaskabovich on 12/13/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import BigInt

struct TokenConstants {
    struct Ethereum {
        static let ethereumDecimals = 18
        static let ethereumContract = "0x0"
        static let ethereumSymbol = "ETH"
    }
}

class HyperlootTokenTransformer {
    
    static func token(from contractable: TokenContractable, balance: String) -> HyperlootToken? {
        guard let type = contractable.type else { return nil }
        
        var tokenType: HyperlootToken.TokenType? = nil
        
        switch type {
        case "ERC-20":
            if let amount = BigInt(balance) {
                let amountString = EtherNumberFormatter.full.string(from: amount, decimals: contractable.decimals ?? 0)
                tokenType = .erc20(amount: amountString)
            }
        case "ERC-721":
            tokenType = .erc721(tokenId: HyperlootToken.Constants.noTokenId, totalCount: Int(balance) ?? 0, attributes: HyperlootToken.Attributes(description: "", name: "", imageURL: ""))
        default:
            break
        }
        
        guard let hyperlootTokenType = tokenType else { return nil }
        
        return HyperlootToken(contractAddress: contractable.contractAddress ?? "",
                              name: contractable.name ?? "",
                              symbol: contractable.symbol ?? "",
                              decimals: contractable.decimals ?? 0,
                              totalSupply: contractable.totalSupply ?? "",
                              type: hyperlootTokenType)
    }
}
