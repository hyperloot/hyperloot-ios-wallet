//
//  EthEstimateGasResponse.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation
import ObjectMapper

struct EthEstimateGasResponse: ImmutableMappable {
    
    let gasLimit: String?
    
    init(map: Map) throws {
        gasLimit = try? map.value("result")
    }
}
