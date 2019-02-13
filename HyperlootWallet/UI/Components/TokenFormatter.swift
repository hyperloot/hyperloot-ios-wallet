//
//  TokenFormatter.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import BigInt

class TokenFormatter {
    
    static func isTo(walletAddress: String, transaction: HyperlootTransaction) -> Bool {
        if transaction.to.lowercased() == walletAddress.lowercased() {
            return true
        } else if transaction.from.lowercased() == walletAddress.lowercased() {
            return false
        }
        
        return false
    }
    
    static func erc20Value(from value: String, decimals: Int, symbol: String) -> String {
        guard let amount = BigInt(value) else { return "0" }
        return "\(EtherNumberFormatter.full.string(from: amount, decimals: decimals)) \(symbol)"
    }
    
    static func tokenDisplay(name: String, symbol: String) -> String {
        return "\(name) (\(symbol))"
    }
    
    static func erc20Value(formattedValue: String, symbol: String) -> String {
        return "\(formattedValue) \(symbol)"
    }
    
    static func erc721Total(count: Int) -> String {
        return "\(count) items"
    }

    static func erc721NameAndTotal(count: Int, tokenName: String) -> String {
        let total = erc721Total(count: count)
        return "\(tokenName), \(total)"
    }
    
    static func erc721Value(tokenId: String) -> String {
        return "#ID [\(tokenId)]"
    }
}
