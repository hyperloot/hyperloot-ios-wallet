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
}

extension HyperlootToken {
    
    init(amount: String, contract: HyperlootTokenContract, blockchain: Blockchain) {
        
        let type: TokenType
        switch contract.type {
        case .ether:
            type = .ether(amount: amount)
        case .erc20:
            type = .erc20(amount: amount)
        case .erc721:
            type = .erc721(tokenId: Constants.noTokenId, totalCount: 0, attributes: nil)
        }
        
        self.init(contractAddress: contract.addressOrMainnetAddress(blockchain: blockchain),
                  name: contract.name,
                  symbol: contract.symbol,
                  decimals: contract.decimals,
                  totalSupply: "0",
                  type: type,
                  blockchain: blockchain,
                  tokenImageURL: nil,
                  description: nil,
                  shortDescription: nil,
                  externalLink: nil)
    }
    
    static func ether(amount: String, blockchain: Blockchain) -> HyperlootToken {
        return HyperlootToken(amount: amount, contract: TokenContracts.ethereum, blockchain: blockchain)
    }
    
    static func defaultTokens(blockchain: Blockchain) -> [HyperlootToken] {
        let amount: String = "0"
        
        let defaultContracts = [
            TokenContracts.hyperloot,
            TokenContracts.poa,
            TokenContracts.byteball,
            TokenContracts.flip,
            TokenContracts.dmarket,
            TokenContracts.wax,
            TokenContracts.enjinCoin,
            TokenContracts.eGold,
            TokenContracts.refereum
        ]
        
        return defaultContracts.map { HyperlootToken(amount: amount, contract: $0, blockchain: blockchain) }
    }
}
