//
//  BlockscoutTransactionResponse.swift
//  HyperlootWallet
//
//  Created by valery_vaskabovich on 12/15/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import ObjectMapper

struct BlockscoutTransactionListResponse: ImmutableMappable {

    struct Transaction: ImmutableMappable, TransactionDefining {
        var blockHash: String?
        var blockNumber: String?
        var confirmations: String?
        var contractAddress: String?
        var cumulativeGasUsed: String?
        var from: String?
        var gas: String?
        var gasPrice: String?
        var gasUsed: String?
        var hash: String?
        var input: String?
        var nonce: String?
        var timeStamp: String?
        var to: String?
        var tokenDecimal: String? // if it's empty then this is ERC-721 token
        var tokenName: String?
        var tokenSymbol: String?
        var transactionIndex: String?
        var value: String? // If tokenDecimal is empty then it's an ERC-721 token and there will be tokenID value
        
        init(map: Map) throws {
            blockHash = try? map.value("blockHash")
            blockNumber = try? map.value("blockNumber")
            confirmations = try? map.value("confirmations")
            contractAddress = try? map.value("contractAddress")
            cumulativeGasUsed = try? map.value("cumulativeGasUsed")
            from = try? map.value("from")
            gas = try? map.value("gas")
            gasPrice = try? map.value("gasPrice")
            gasUsed = try? map.value("gasUsed")
            hash = try? map.value("hash")
            input = try? map.value("input")
            nonce = try? map.value("nonce")
            timeStamp = try? map.value("timeStamp")
            to = try? map.value("to")
            tokenDecimal = try? map.value("tokenDecimal")
            tokenName = try? map.value("tokenName")
            tokenSymbol = try? map.value("tokenSymbol")
            transactionIndex = try? map.value("transactionIndex")
            value = try? map.value("value")
        }
    }
    
    var transactions: [Transaction]?
    
    init(map: Map) throws {
        transactions = try? map.value("result")
    }

}
