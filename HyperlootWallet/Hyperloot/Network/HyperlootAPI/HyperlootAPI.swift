//
//  HyperlootAPI.swift
//  HyperlootWallet
//

import Foundation
import Alamofire

class HyperlootAPI: HTTPService {
    
    required public init(config: HyperlootConfig) {
        let host = URL(string: config.apiURL)!
        super.init(host: host)
    }
    
    @discardableResult
    func canRegister(email: String, completion: @escaping (Bool?, Error?) -> Void) -> Cancelable {
        let parameters = ["email": email]
        return request("/api/canRegisterEmail", keyPath: "result", method: .get, parameters: parameters, objectCompletion: { (response: CanRegisterEmailResponse?, error) in
            if let response = response {
                completion(response.isAvailable, nil)
            } else {
                completion(nil, error)
            }
        })
    }
    
    @discardableResult
    func login(email: String, password: String, completion: @escaping (LoginResponse?, Error?) -> Void) -> Cancelable {
        let parameters = ["email": email, "password": password]
        return request("/api/login", keyPath: "result", method: .post, parameters: parameters, encoding: JSONEncoding.default, objectCompletion: { (response: LoginResponse?, error) in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        })
    }
    
    @discardableResult
    func signup(email: String, password: String, nickname: String, walletAddress: String, completion: @escaping (SignupResponse?, Error?) -> Void) -> Cancelable {
        let parameters = ["email": email, "password": password, "nickname": nickname, "walletAddress": walletAddress]
        return request("/api/signup", keyPath: "result", method: .post, parameters: parameters, encoding: JSONEncoding.default, objectCompletion: { (response: SignupResponse?, error) in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        })
    }
}
