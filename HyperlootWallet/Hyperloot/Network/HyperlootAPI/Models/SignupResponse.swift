//
//  SignupResponse.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import ObjectMapper

struct SignupResponse: ImmutableMappable {
    let email: String
    let userId: String
    
    init(map: Map) throws {
        email = try map.value("email")
        userId = try map.value("id")
    }
}
