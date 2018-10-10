//
//  HyperlootNickname.swift
//  HyperlootWallet
//
//  Created by valery_vaskabovich on 10/8/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

struct HyperlootNickname {
    let name: String
    let identifier: Int
    
    public static func ==(lhs: HyperlootNickname, rhs: HyperlootNickname) -> Bool {
        return lhs.name == rhs.name && lhs.identifier == rhs.identifier
    }
}

extension HyperlootNickname: Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case identifier
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try values.decode(String.self, forKey: .name)
        identifier = try values.decode(Int.self, forKey: .identifier)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(identifier, forKey: .identifier)
    }
}
