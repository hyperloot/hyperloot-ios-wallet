//
//  HyperlootTokenPrice.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation

struct HyperlootTokenPrice: Codable {
    let symbol: String
    let price: Double
    let percentChange1h: Double
    let percentChange24h: Double
    let percentChange7d: Double
}
