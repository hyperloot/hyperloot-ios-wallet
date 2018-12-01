//
//  HTTPService.swift
//  HyperlootWallet
//
//  Created by valery_vaskabovich on 11/30/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import AlamofireObjectMapper

protocol Cancelable {
    func cancel()
}

extension Request: Cancelable {}

class HTTPService {
    
    let sessionManager: SessionManager
    let host: URL
    
    init(host: URL, sessionManager: SessionManager = SessionManager.default) {
        self.host = host
        self.sessionManager = sessionManager
    }
    
    public func request<T: BaseMappable>(_ path: String,
                                         keyPath: String? = nil,
                                         method: HTTPMethod = .get,
                                         parameters: Parameters? = nil,
                                         encoding: ParameterEncoding = URLEncoding.default,
                                         headers: HTTPHeaders? = nil,
                                         completion: @escaping (T?, Error?) -> Void) -> DataRequest {
        
        let url: URL = host.appendingPathComponent(path)
        return sessionManager.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers).responseObject(keyPath: keyPath, completionHandler: { (response: DataResponse<T>) in
            completion(response.result.value, response.result.error)
        })
    }
}
