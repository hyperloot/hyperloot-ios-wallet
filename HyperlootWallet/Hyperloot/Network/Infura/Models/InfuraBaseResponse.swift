//
//  InfuraBaseResponse.swift
//  HyperlootWallet
//
//  Created by valery_vaskabovich on 1/27/19.
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation
import ObjectMapper

struct InfuraBaseResponse: ImmutableMappable {

    let chainId: String?
    let jsonRpc: String?
    let result: Any?

    init(map: Map) throws {
        chainId = try? map.value("id")
        jsonRpc = try? map.value("jsonRpc")
        result = try? map.value("result")
    }
}
