//
//  OpenSeaTokenOwner.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation
import ObjectMapper

struct OpenSeaTokenOwner: ImmutableMappable {
    
    struct User: ImmutableMappable {
        let username: String?
        
        init(map: Map) throws {
            username = try? map.value("username")
        }
    }
    
    let address: String?
    let profileImageURL: String?
    let user: User?
    let config: String?
    
    init(map: Map) throws {
        address = try? map.value("address")
        profileImageURL = try? map.value("profile_img_url")
        user = try? map.value("user")
        config = try? map.value("config")
    }
}
