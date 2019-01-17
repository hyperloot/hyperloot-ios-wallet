//
//  BlockscoutTokenListResponse.swift
//  HyperlootWallet
//
//  Created by valery_vaskabovich on 12/5/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import ObjectMapper

struct BlockscoutTokenListResponse: ImmutableMappable {
    
    struct Token: ImmutableMappable {
        let balance: String?
        let contractAddress: String?
        let decimals: Int?
        let name: String?
        let symbol: String?
        
        init(map: Map) throws {
            balance = try? map.value("balance")
            contractAddress = try? map.value("contractAddress")
            decimals = try? map.value("decimals", using: StringToIntTransformer())
            name = try? map.value("name")
            symbol = try? map.value("symbol")
        }
    }
    
    let tokens: [Token]?
    
    init(map: Map) throws {
        tokens = try? map.value("result")
    }
}
