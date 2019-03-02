//
//  CoinMarketCapBaseResponse.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation
import ObjectMapper

struct CoinMarketCapBaseResponse: ImmutableMappable {
    var errorCode: Int?
    var errorMessage: String?
    
    init(map: Map) throws {
        errorCode <- map["status.error_code"]
        errorMessage <- map["status.error_message"]
    }
}
