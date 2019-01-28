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
    
    let result: String?

    init(map: Map) throws {
        result = try? map.value("result")
    }
}
