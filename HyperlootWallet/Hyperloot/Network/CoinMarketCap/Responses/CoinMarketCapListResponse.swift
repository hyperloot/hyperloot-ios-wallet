//
//  CoinMarketCapListResponse:.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation
import ObjectMapper

struct CoinMarketCapListResponse: ImmutableMappable {
    
    struct CryptoCurrencyData: ImmutableMappable {
        
        struct Price: ImmutableMappable {
            var price: Double?
            var lastUpdated: Date?
            
            var percentChange1h: Double?
            var percentChange24h: Double?
            var percentChange7d: Double?
            
            init(map: Map) throws {
                price <- map["price"]
                
                percentChange1h <- map["percent_change_1h"]
                percentChange24h <- map["percent_change_24h"]
                percentChange7d <- map["percent_change_7d"]
                
                lastUpdated = try? map.value("last_updated", using: ISO8601DateTransform())
            }
        }
        
        var id: String?
        var name: String?
        var symbol: String?
        var quote: [String: Price]?
        
        init(map: Map) throws {
            id <- map["id"]
            name <- map["name"]
            symbol <- map["symbol"]
            quote <- map["quote"]
        }
    }
    
    var data: [String: CryptoCurrencyData]?
    
    init(map: Map) throws {
        data <- map["data"]
    }
}
