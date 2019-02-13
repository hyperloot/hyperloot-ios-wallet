//
//  EthSendRawTransactionResponse.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation
import ObjectMapper

struct EthSendRawTransactionResponse: ImmutableMappable {
    
    let transactionHash: String? // DATA, 32 Bytes - the transaction hash, or the zero hash if the transaction is not yet available.
    
    init(map: Map) throws {
        transactionHash = try? map.value("result")
    }
}
