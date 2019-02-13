//
//  BlockscoutBalanceResponse.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import ObjectMapper

struct BlockscoutBalanceResponse: ImmutableMappable {
    
    let balance: String?
    
    init(map: Map) throws {
        balance = try? map.value("result")
    }
}
