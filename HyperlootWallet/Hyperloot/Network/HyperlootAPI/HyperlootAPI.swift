//
//  HyperlootAPI.swift
//  HyperlootWallet
//

import Foundation
import Alamofire

class HyperlootAPI: HTTPService {
    
    enum Environment: String {
        case testNet = "https://api-testnet.hyperloot.net"
    }
    
    required public init(environment: Environment) {
        let host = URL(string: environment.rawValue)!
        super.init(host: host)
    }
    
    @discardableResult
    func canRegister(email: String, completion: @escaping (Bool?, Error?) -> Void) -> Cancelable {
        let parameters = ["email": email]
        return request("/api/canRegisterEmail", keyPath: "result", method: .get, parameters: parameters, completion: { (response: CanRegisterEmailResponse?, error) in
            if let response = response {
                completion(response.canRegister, nil)
            } else {
                completion(nil, error)
            }
        })
    }
}
