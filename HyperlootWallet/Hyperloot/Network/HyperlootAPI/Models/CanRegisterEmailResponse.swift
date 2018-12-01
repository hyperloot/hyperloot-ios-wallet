//
//  CanRegisterEmailResponse.swift
//  HyperlootWallet
//
//  Created by valery_vaskabovich on 12/1/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import ObjectMapper

struct CanRegisterEmailResponse: ImmutableMappable {
    let email: String
    let canRegister: Bool
    
    init(map: Map) throws {
        email = try map.value("email")
        canRegister = try map.value("result")
    }
}
