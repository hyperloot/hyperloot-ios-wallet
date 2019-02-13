//
//  HyperlootTransaction.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

enum HyperlootTransactionType {
    case transactions
    case tokens(contractAddress: String)
}

enum HyperlootTransactionValue {
    case ether(value: String)
    case token(value: String, decimals: Int, symbol: String)
    case uniqueToken(tokenId: String)
}

struct HyperlootTransaction {

    enum Status: Int, Codable {
        case error = 0
        case success = 1
        case pending = 2
    }
    
    let transactionHash: String
    let contractAddress: String
    let timestamp: TimeInterval
    let from: String
    let to: String
    let status: Status
    let value: HyperlootTransactionValue
}
