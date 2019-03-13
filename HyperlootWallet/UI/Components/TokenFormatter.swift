//
//  TokenFormatter.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import BigInt

class TokenFormatter {
    
    static var priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = NSLocale.current
        return formatter
    } ()
    
    static func isTo(walletAddress: String, transaction: HyperlootTransaction) -> Bool {
        if transaction.to.lowercased() == walletAddress.lowercased() {
            return true
        } else if transaction.from.lowercased() == walletAddress.lowercased() {
            return false
        }
        
        return false
    }
    
    static func erc20Value(from value: String, decimals: Int, symbol: String) -> String {
        var erc20Value: String = "0"
        if let amount = BigInt(value) {
            erc20Value = EtherNumberFormatter.full.string(from: amount, decimals: decimals)
        }
        return "\(symbol) Ξ \(erc20Value)"
    }
    
    static func erc20BalanceToDouble(from value: String, decimals: Int) -> Double {
        guard let amount = BigInt(value) else { return 0 }
        return Double(EtherNumberFormatter.full.string(from: amount, decimals: decimals)) ?? 0
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
    
    static func erc721Token(itemName: String?, tokenName: String, tokenId: String) -> String {
        return itemName ?? "\(tokenName) #\(tokenId)"
    }
    
    static func formattedPrice(doubleValue: Double) -> String {
        return priceFormatter.string(from: NSNumber(value: doubleValue)) ?? "0.00"
    }
}
