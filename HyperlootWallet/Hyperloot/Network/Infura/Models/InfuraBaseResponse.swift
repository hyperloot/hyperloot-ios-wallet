//
//  InfuraBaseResponse.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation
import ObjectMapper

struct InfuraBaseResponse: ImmutableMappable {

    let chainId: Int?
    let jsonRpc: String?
    let result: Any?
    let error: ResponseError?
    
    struct ResponseError: ImmutableMappable {
        let code: String?
        let message: String?
        
        init(map: Map) throws {
            code = try? map.value("code")
            message = try? map.value("message")
        }
    }

    init(map: Map) throws {
        chainId = try? map.value("id")
        jsonRpc = try? map.value("jsonrpc")
        result = try? map.value("result")
        error = try? map.value("error")
    }
}
