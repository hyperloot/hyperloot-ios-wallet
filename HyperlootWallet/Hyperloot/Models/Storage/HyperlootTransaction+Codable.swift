//
//  HyperlootTransaction+Codable.swift
//  HyperlootWallet
//
//  Created by valery_vaskabovich on 12/27/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

extension HyperlootTransaction: Codable {
        
    enum CodingKeys: String, CodingKey {
        case transactionHash
        case contractAddress
        case timestamp
        case from
        case to
        case status
        case value
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        transactionHash = try values.decode(String.self, forKey: .transactionHash)
        contractAddress = try values.decode(String.self, forKey: .contractAddress)
        timestamp = try values.decode(TimeInterval.self, forKey: .timestamp)
        from = try values.decode(String.self, forKey: .from)
        to = try values.decode(String.self, forKey: .to)
        status = try values.decode(Status.self, forKey: .status)
        value = try values.decode(HyperlootTransactionValue.self, forKey: .value)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(transactionHash, forKey: .transactionHash)
        try container.encode(contractAddress, forKey: .contractAddress)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(from, forKey: .from)
        try container.encode(to, forKey: .to)
        try container.encode(status, forKey: .status)
        try container.encode(value, forKey: .value)
    }
}

extension HyperlootTransactionValue: Codable {
    
    struct CodingConstants {
        static let tokenTypeEther = "Ether"
        static let tokenTypeToken = "Token"
        static let tokenTypeUniqueToken = "UniqueToken"
    }
    
    enum CodingKeys: String, CodingKey {
        case transactionValueType
        case tokenValue
        case tokenDecimals
        case tokenSymbol
        case uniqueTokenId
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let tokenType = try values.decode(String.self, forKey: .transactionValueType)
        switch tokenType {
        case CodingConstants.tokenTypeToken:
            let amount = try values.decode(String.self, forKey: .tokenValue)
            let symbol = try values.decode(String.self, forKey: .tokenSymbol)
            let decimals = try values.decode(Int.self, forKey: .tokenDecimals)
            self = .token(value: amount, decimals: decimals, symbol: symbol)
        case CodingConstants.tokenTypeUniqueToken:
            let tokenId = try values.decode(String.self, forKey: .uniqueTokenId)
            self = .uniqueToken(tokenId: tokenId)
        case CodingConstants.tokenTypeEther:
            fallthrough
        default:
            let amount = try values.decode(String.self, forKey: .tokenValue)
            self = .ether(value: amount)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .ether(value: let amount):
            try container.encode(CodingConstants.tokenTypeEther, forKey: .transactionValueType)
            try container.encode(amount, forKey: .tokenValue)
        case .token(value: let amount, decimals: let decimals, symbol: let symbol):
            try container.encode(CodingConstants.tokenTypeToken, forKey: .transactionValueType)
            try container.encode(amount, forKey: .tokenValue)
            try container.encode(decimals, forKey: .tokenDecimals)
            try container.encode(symbol, forKey: .tokenSymbol)
        case .uniqueToken(tokenId: let tokenId):
            try container.encode(CodingConstants.tokenTypeUniqueToken, forKey: .transactionValueType)
            try container.encode(tokenId, forKey: .uniqueTokenId)
        }
    }
}
