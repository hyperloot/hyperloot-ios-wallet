//
//  EthGetTransactionCountResponse.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation
import ObjectMapper

struct EthGetTransactionCountResponse: ImmutableMappable {
    
    let numberOfTransactions: String?

    init(map: Map) throws {
        numberOfTransactions = try? map.value("result")
    }
}
