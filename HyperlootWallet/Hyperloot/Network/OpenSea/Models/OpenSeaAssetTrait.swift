//
//  OpenSeaAssetTrait.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation
import ObjectMapper

struct OpenSeaAssetTrait: ImmutableMappable {
    
    let traitType: String?
    let value: String?
    let displayType: String?
    let maxValue: String?
    
    init(map: Map) throws {
        traitType = try? map.value("trait_type")
        value = try? map.value("value")
        displayType = try? map.value("display_type")
        maxValue = try? map.value("max_value")
    }
}
