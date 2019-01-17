//
//  HyperlootTransactionsTransformer.swift
//  HyperlootWallet
//
//  Created by valery_vaskabovich on 12/19/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

class HyperlootTransactionsTransformer {
    
    static func transaction(from transaction: TransactionDefining) -> HyperlootTransaction? {
        guard let transactionHash = transaction.hash,
            let timestampString = transaction.timeStamp,
            let timestamp = Double(timestampString),
            let from = transaction.from,
            let to = transaction.to,
            let transactionValue = transaction.value,
            let contractAddress = transaction.contractAddress else {
                return nil
        }
        
        let value: HyperlootTransactionValue
        
        if contractAddress.isEmpty {
            value = .ether(value: transactionValue)
        } else {
            if let decimalsString = transaction.tokenDecimal, decimalsString.isEmpty == false, let decimals = Int(decimalsString) {
                value = .token(value: transactionValue, decimals: decimals, symbol: transaction.tokenSymbol ?? "")
            } else {
                value = .uniqueToken(tokenId: transactionValue)
            }
        }
        
        return HyperlootTransaction(transactionHash: transactionHash,
                                    contractAddress: contractAddress,
                                    timestamp: timestamp,
                                    from: from,
                                    to: to,
                                    status: .success,
                                    value: value)
    }
    
}
