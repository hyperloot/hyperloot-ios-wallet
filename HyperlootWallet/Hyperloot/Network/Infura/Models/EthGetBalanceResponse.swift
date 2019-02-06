//
//  EthGetBalanceResponse.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation

import ObjectMapper

struct EthGetBalanceResponse: ImmutableMappable {
    
    let balanceHex: String? // QUANTITY - integer of the current balance in wei. (but the value itself is in Hex format)
    
    init(map: Map) throws {
        balanceHex = try? map.value("result")
    }
}
