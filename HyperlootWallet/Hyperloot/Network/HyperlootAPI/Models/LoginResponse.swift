//
//  LoginResponse.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import ObjectMapper

struct LoginResponse: ImmutableMappable {
    
    struct Nickname: ImmutableMappable {
        let nickname: String
        let identifier: Int
        
        init(map: Map) throws {
            nickname = try map.value("nickname")
            identifier = try map.value("identifier")
        }
    }
    
    let email: String
    let userId: String
    let accessToken: String
    let nickname: Nickname
    let walletAddress: String
    
    init(map: Map) throws {
        email = try map.value("email")
        userId = try map.value("userId")
        accessToken = try map.value("accessToken")
        nickname = try map.value("nickname")
        walletAddress = try map.value("walletAddress")
    }
}
