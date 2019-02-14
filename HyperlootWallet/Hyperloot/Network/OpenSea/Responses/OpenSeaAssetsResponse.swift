//
//  OpenSeaAssetsResponse.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation
import ObjectMapper

struct OpenSeaAssetsResponse: ImmutableMappable {
    
    let count: Int
    let assets: [OpenSeaAsset]
    
    init(map: Map) throws {
        count = (try? map.value("count")) ?? 0
        assets = (try? map.value("assets")) ?? []
    }
}
