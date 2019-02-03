//
//  EthGasPriceResponse.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation
import ObjectMapper

struct EthGasPriceResponse: ImmutableMappable {
    
    let gasPrice: String? // Returns gas price in hex
    
    init(map: Map) throws {
        gasPrice = try? map.value("result")
    }
}


