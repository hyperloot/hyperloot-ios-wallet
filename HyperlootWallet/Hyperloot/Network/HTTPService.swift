//
//  HTTPService.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 11/30/18.
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
    
    typealias ResponseValidation = (_ responseObject: Any?) -> Error?
    
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
                                         validation: ResponseValidation? = nil,
                                         objectCompletion: @escaping (T?, Error?) -> Void) -> DataRequest {
        return request(path, method: method, parameters: parameters, encoding: encoding, headers: headers, validation: validation).responseObject(keyPath: keyPath, completionHandler: { (response: DataResponse<T>) in
            objectCompletion(response.result.value, response.result.error)
        })
    }
    
    public func request<T: BaseMappable>(_ path: String,
                                         keyPath: String? = nil,
                                         method: HTTPMethod = .get,
                                         parameters: Parameters? = nil,
                                         encoding: ParameterEncoding = URLEncoding.default,
                                         headers: HTTPHeaders? = nil,
                                         validation: ResponseValidation? = nil,
                                         arrayCompletion: @escaping ([T]?, Error?) -> Void) -> DataRequest {
        return request(path, method: method, parameters: parameters, encoding: encoding, headers: headers, validation: validation).responseArray(keyPath: keyPath, completionHandler: { (response: DataResponse<[T]>) in
            arrayCompletion(response.result.value, response.result.error)
        })
    }
    
    // MARK: - Private
    private func request(_ path: String,
                         method: HTTPMethod = .get,
                         parameters: Parameters? = nil,
                         encoding: ParameterEncoding = URLEncoding.default,
                         headers: HTTPHeaders? = nil,
                         validation: ResponseValidation? = nil) -> DataRequest {
        let url: URL = host.appendingPathComponent(path)
        return sessionManager.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers).validate({ (request, response, data) -> Request.ValidationResult in
            print("URL Request: \(String(describing:request?.url?.absoluteString)), parameters: \(String(describing:parameters))")
            return self.validate(request: request, response: response, data: data, responseValidation: validation)
        })
    }
    
    private func validate(request: URLRequest?, response: HTTPURLResponse, data: Data?, responseValidation: ResponseValidation?) -> Request.ValidationResult {
        let jsonResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
        let result = jsonResponseSerializer.serializeResponse(request, response, data, nil)
        
        if let error = responseValidation?(result.value) {
            return .failure(error)
        }
        
        if let data = data {
            let obj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
            print(String(describing:obj))
        }
        
        return .success
    }
}
