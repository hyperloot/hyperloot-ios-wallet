//
//  OpenSeaAsset.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation
import ObjectMapper

struct OpenSeaAsset: ImmutableMappable {
    
    let tokenId: String?
    let imageURL: String?
    let backgroundColor: String?
    let name: String?
    let externalLink: String?
    let assetContract: OpenSeaContract?
    let owner: OpenSeaTokenOwner?
    let traits: [OpenSeaAssetTrait]
    let openSeaLink: String?
    
    init(map: Map) throws {
        tokenId = try? map.value("token_id")
        imageURL = try? map.value("image_url")
        backgroundColor = try? map.value("background_color")
        name = try? map.value("name")
        externalLink = try? map.value("external_link")
        assetContract = try? map.value("asset_contract")
        owner = try? map.value("owner")
        traits = (try? map.value("traits")) ?? []
        openSeaLink = try? map.value("permalink")
    }
}
