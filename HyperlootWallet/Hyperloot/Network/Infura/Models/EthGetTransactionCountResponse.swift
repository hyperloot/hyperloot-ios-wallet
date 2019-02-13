//
//  EthGetTransactionCountResponse.swift
//  HyperlootWallet
//
//  Created by valery_vaskabovich on 1/27/19.
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
