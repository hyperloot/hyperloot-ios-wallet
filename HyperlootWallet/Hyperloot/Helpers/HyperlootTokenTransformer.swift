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
    
    static func token(from contractable: TokenContractable, balance: String, blockchain: Blockchain) -> HyperlootToken? {
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
                              type: hyperlootTokenType,
                              blockchain: blockchain)
    }
    
    static func token(from token: HyperlootToken, balance: String, blockchain: Blockchain) -> HyperlootToken {
        let type: HyperlootToken.TokenType
        switch token.type {
        case .erc20(amount: let prevAmount):
            if let amount = BigInt(balance) {
                let amountString = EtherNumberFormatter.full.string(from: amount, decimals: token.decimals)
                type = .erc20(amount: amountString)
            } else {
                type = .erc20(amount: prevAmount)
            }
        case .erc721(tokenId: let tokenId, totalCount: _, attributes: let attributes):
            type = .erc721(tokenId: tokenId, totalCount: Int(balance) ?? 0, attributes: attributes)
        }
        
        return HyperlootToken(contractAddress: token.contractAddress,
                              name: token.name,
                              symbol: token.symbol,
                              decimals: token.decimals,
                              totalSupply: token.totalSupply,
                              type: type,
                              blockchain: blockchain)
    }
    
    static func tokenizedItem(from token: HyperlootToken, tokenId: String, attributes: HyperlootToken.Attributes) -> HyperlootToken? {
        guard token.isERC721(),
            case .erc721(tokenId: _, totalCount: let totalCount, attributes: _) = token.type else {
            return nil
        }
        
        return HyperlootToken(contractAddress: token.contractAddress,
                              name: token.name,
                              symbol: token.symbol,
                              decimals: token.decimals,
                              totalSupply: token.totalSupply,
                              type: .erc721(tokenId: tokenId, totalCount: totalCount, attributes: attributes),
                              blockchain: token.blockchain)
    }
}
