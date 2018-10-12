//
//  HyperlootUser.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 9/17/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import TrustCore

struct HyperlootUser {
    let email: String
    let nickname: HyperlootNickname
    let walletAddress: Address
}

extension HyperlootUser: Codable {
    enum CodingKeys: String, CodingKey {
        case email
        case nickname
        case walletAddress
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        email = try values.decode(String.self, forKey: .email)
        nickname = try values.decode(HyperlootNickname.self, forKey: .nickname)
        walletAddress = Address(data: try values.decodeHexString(forKey: .walletAddress))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(email, forKey: .email)
        try container.encode(nickname, forKey: .nickname)
        try container.encode(walletAddress.description.drop0x(), forKey: .walletAddress)
    }
}

private extension String {
    func drop0x() -> String {
        if hasPrefix("0x") {
            return String(dropFirst(2))
        }
        return self
    }
}
