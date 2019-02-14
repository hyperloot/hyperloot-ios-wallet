//
//  HyperlootERC20Token.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import TrustCore

struct HyperlootToken {
    
    struct Constants {
        static let noTokenId = "noTokenId"
    }
        
    struct Attributes: Codable {
        struct Trait: Codable {
            let type: String
            let value: String
        }
        let description: String
        let shortDescription: String?
        let name: String
        let imageURL: String?
        let traits: [Trait]
    }
    
    enum TokenType {
        case ether(amount: String)
        case erc20(amount: String)
        case erc721(tokenId: String, totalCount: Int, attributes: Attributes?)
    }
    
    let contractAddress: String
    let name: String
    let symbol: String
    let decimals: Int
    let totalSupply: String
    let type: TokenType
    let blockchain: Blockchain
    
    // Optional attributes for contract
    let tokenImageURL: String?
    let description: String?
    let shortDescription: String?
    let externalLink: String?
    
    static func ether(amount: String, blockchain: Blockchain) -> HyperlootToken {
        return HyperlootToken(contractAddress: TokenConstants.Ethereum.ethereumContract,
                              name: "Ethereum",
                              symbol: TokenConstants.Ethereum.ethereumSymbol,
                              decimals: TokenConstants.Ethereum.ethereumDecimals,
                              totalSupply: "0",
                              type: .ether(amount: amount),
                              blockchain: blockchain,
                              tokenImageURL: nil,
                              description: nil,
                              shortDescription: nil,
                              externalLink: nil)
    }
    
    static func hlt(amount: String, blockchain: Blockchain) -> HyperlootToken {
        // TODO: fill the information
        return HyperlootToken(contractAddress: "0x0",
                              name: "Hyperloot",
                              symbol: "HLT",
                              decimals: 18,
                              totalSupply: "0",
                              type: .erc20(amount: amount),
                              blockchain: blockchain,
                              tokenImageURL: nil,
                              description: nil,
                              shortDescription: nil,
                              externalLink: nil)
    }
}
