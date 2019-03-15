//
//  NicknameSearchSuggestionResponse.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation
import ObjectMapper

struct HyperlootUserSuggestion: ImmutableMappable {
    
    let nickname: String
    let identifier: Int
    let walletAddress: String
    
    init(map: Map) throws {
        nickname = try map.value("nickname")
        identifier = try map.value("identifier")
        walletAddress = (try? map.value("walletAddress")) ?? ""
    }
}

