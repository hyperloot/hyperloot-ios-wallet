//
//  TransactionDefining.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

protocol TransactionDefining {
    
    var blockHash: String? { get }
    var blockNumber: String? { get }
    var confirmations: String? { get }
    var contractAddress: String? { get }
    var cumulativeGasUsed: String? { get }
    var from: String? { get }
    var gas: String? { get }
    var gasPrice: String? { get }
    var gasUsed: String? { get }
    var hash: String? { get }
    var input: String? { get }
    var nonce: String? { get }
    var timeStamp: String? { get }
    var to: String? { get }
    var tokenDecimal: String? { get }
    var tokenName: String? { get }
    var tokenSymbol: String? { get }
    var transactionIndex: String? { get }
    var value: String? { get }
    
    
}
