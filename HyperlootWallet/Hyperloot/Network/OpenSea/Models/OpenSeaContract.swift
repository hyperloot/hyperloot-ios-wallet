//
//  OpenSeaContract.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation
import ObjectMapper

struct OpenSeaContract: ImmutableMappable {
    
    let address: String?
    let name: String?
    let symbol: String?
    let imageURL: String?
    let description: String?
    let shortDescription: String?
    let externalLink: String?
    
    init(map: Map) throws {
        address = try? map.value("address")
        name = try? map.value("name")
        symbol = try? map.value("symbol")
        imageURL = try? map.value("image_url")
        description = try? map.value("description")
        shortDescription = try? map.value("short_description")
        externalLink = try? map.value("external_link")
    }
}
