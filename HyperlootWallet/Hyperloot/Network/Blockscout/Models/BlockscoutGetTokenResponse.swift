//
//  BlockscoutGetTokenResponse.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import ObjectMapper

struct BlockscoutGetTokenResponse: ImmutableMappable {
    
    struct Token: ImmutableMappable, TokenContractable {
        let contractAddress: String?
        let decimals: Int?
        let name: String?
        let symbol: String?
        let totalSupply: String?
        let type: String?
        
        init(map: Map) throws {
            contractAddress = try? map.value("contractAddress")
            decimals = try? map.value("decimals", using: StringToIntTransformer())
            name = try? map.value("name")
            symbol = try? map.value("symbol")
            totalSupply = try? map.value("totalSupply")
            type = try? map.value("type")
        }
    }
    
    let token: Token?
    
    init(map: Map) throws {
        token = try? map.value("result")
    }
}
