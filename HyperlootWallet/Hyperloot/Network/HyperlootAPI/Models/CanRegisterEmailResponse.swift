//
//  CanRegisterEmailResponse.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 12/1/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import ObjectMapper

struct CanRegisterEmailResponse: ImmutableMappable {
    let email: String
    let isAvailable: Bool
    
    init(map: Map) throws {
        email = try map.value("email")
        isAvailable = try map.value("isAvailable")
    }
}
