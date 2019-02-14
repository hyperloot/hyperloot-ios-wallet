//
//  HyperlootToken+Codable.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

extension HyperlootToken.TokenType: Codable {
    
    struct CodingConstants {
        static let erc20TokenType = "ERC-20"
        static let erc721TokenType = "ERC-721"
    }
    
    enum CodingKeys: String, CodingKey {
        case tokenType
        
        case erc20Amount
        
        case erc721TokenId
        case erc721TotalCount
        case erc721Attributes
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let type = try container.decode(String.self, forKey: .tokenType)
        switch type {
        case CodingConstants.erc721TokenType:
            let tokenId = try container.decode(String.self, forKey: .erc721TokenId)
            let totalCount = try container.decode(Int.self, forKey: .erc721TotalCount)
            let attributes = try? container.decode(HyperlootToken.Attributes.self, forKey: .erc721Attributes)
            self = .erc721(tokenId: tokenId, totalCount: totalCount, attributes: attributes)
        case CodingConstants.erc20TokenType:
            fallthrough
        default:
            let amount = try container.decode(String.self, forKey: .erc20Amount)
            self = .erc20(amount: amount)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .ether(amount: let amount):
            fallthrough
        case .erc20(amount: let amount):
            try container.encode(CodingConstants.erc20TokenType, forKey: .tokenType)
            try container.encode(amount, forKey: .erc20Amount)
        case .erc721(tokenId: let tokenId, totalCount: let totalCount, attributes: let attributes):
            try container.encode(CodingConstants.erc721TokenType, forKey: .tokenType)
            try container.encode(tokenId, forKey: .erc721TokenId)
            try container.encode(totalCount, forKey: .erc721TotalCount)
            try? container.encode(attributes, forKey: .erc721Attributes)
        }
    }
}

extension HyperlootToken: Codable {
    
    enum CodingKeys: String, CodingKey {
        case contractAddress
        case name
        case symbol
        case decimals
        case totalSupply
        case type
        case blockchain
        
        case tokenImageURL
        case description
        case shortDescription
        case externalLink
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        contractAddress = try container.decode(String.self, forKey: .contractAddress)
        name = try container.decode(String.self, forKey: .name)
        symbol = try container.decode(String.self, forKey: .symbol)
        decimals = try container.decode(Int.self, forKey: .decimals)
        totalSupply = try container.decode(String.self, forKey: .totalSupply)
        type = try container.decode(TokenType.self, forKey: .type)
        blockchain = try container.decode(Blockchain.self, forKey: .blockchain)
        tokenImageURL = try? container.decode(String.self, forKey: .tokenImageURL)
        description = try? container.decode(String.self, forKey: .description)
        shortDescription = try? container.decode(String.self, forKey: .shortDescription)
        externalLink = try? container.decode(String.self, forKey: .externalLink)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(contractAddress, forKey: .contractAddress)
        try container.encode(name, forKey: .name)
        try container.encode(symbol, forKey: .symbol)
        try container.encode(totalSupply, forKey: .totalSupply)
        try container.encode(decimals, forKey: .decimals)
        try container.encode(type, forKey: .type)
        try container.encode(blockchain, forKey: .blockchain)
        
        try? container.encode(tokenImageURL, forKey: .tokenImageURL)
        try? container.encode(description, forKey: .description)
        try? container.encode(shortDescription, forKey: .shortDescription)
        try? container.encode(externalLink, forKey: .externalLink)
    }
}
