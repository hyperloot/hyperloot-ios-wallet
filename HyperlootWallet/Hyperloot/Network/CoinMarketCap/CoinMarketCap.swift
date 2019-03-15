//
//  CoinMarketCap.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

class CoinMarketCap: HTTPService {
    
    struct Constants {
        static let baseURL = "https://pro-api.coinmarketcap.com";
        static let apiKeyHeaderKey = "X-CMC_PRO_API_KEY"
    }
    
    let apiKey: String
    
    required init(apiKey: String) {
        let host = URL(string: Constants.baseURL)!
        self.apiKey = apiKey
        super.init(host: host)
    }
    
    enum CoinMarketCapRequest: String {
        case metadata = "/v1/cryptocurrency/info"
        case quotes = "/v1/cryptocurrency/quotes/latest"
        case map = "/v1/cryptocurrency/map"
    }
    
    enum CoinMarketCapError: Error {
        case general(code: Int, message: String)
        case invalid(symbols: [String])
    }
    
    private func coinMarketCapError(code: Int, message: String) -> CoinMarketCapError {
        if code == 400 {
            // Find "symbol": "<IDs>" in error message and convert to JSON
            if let range = message.range(of: "\"symbol\"\\s*:\\s*\".*\"", options: .regularExpression) {
                let symbols = "{\(message[range])}"
                if let data = symbols.data(using: .utf8),
                    let dict = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: String],
                    let allSymbols = dict["symbol"] {
                    return .invalid(symbols: allSymbols.components(separatedBy: ","))
                }
            }
        }
        
        return .general(code: code, message: message)
    }
    
    private func validate(object: Any?) -> Error? {
        guard let response = Mapper<CoinMarketCapBaseResponse>().map(JSONObject: object) else {
            return coinMarketCapError(code: -1, message: "Response is not valid")
        }
        
        let errorCode = response.errorCode ?? 0
        let message = response.errorMessage ?? ""
        
        if errorCode == 0 {
            return nil
        }
        
        return coinMarketCapError(code: errorCode, message: message)
    }

    private func coinMarketCapRequest<T>(requestModel: CoinMarketCapRequest, parameters: Parameters? = nil, completion: @escaping (T?, CoinMarketCapError?) -> Void) -> DataRequest where T : BaseMappable {
        let headers: HTTPHeaders = [Constants.apiKeyHeaderKey: apiKey]
        return request(requestModel.rawValue, keyPath: nil, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers, validation: { [weak self] (object) -> Error? in
            return self?.validate(object: object)
        }, objectCompletion: { (result, error) in
            completion(result, error as? CoinMarketCapError)
        })
    }
    
    private func getSymbols(from array: [String]) -> String {
        return array.joined(separator: ",")
    }
    
    @discardableResult
    func map(symbols: [String], completion: @escaping (CoinMarketCapListResponse?, CoinMarketCapError?) -> Void) -> Cancelable {
        let parameters: Parameters = ["symbol": getSymbols(from: symbols)]
        return coinMarketCapRequest(requestModel: .map, parameters: parameters, completion: completion)
    }
    
    @discardableResult
    func quotes(symbols: [String], convertToCurrency: String, completion: @escaping (CoinMarketCapListResponse?, CoinMarketCapError?) -> Void) -> Cancelable {
        let parameters: Parameters = [ "symbol": getSymbols(from: symbols),
                                       "convert": convertToCurrency]
        return coinMarketCapRequest(requestModel: .quotes, parameters: parameters, completion: completion)
    }
    
    @discardableResult
    func metadata(symbols: [String], completion: @escaping (CoinMarketCapListResponse?, CoinMarketCapError?) -> Void) -> Cancelable {
        let parameters: Parameters = [ "symbol": getSymbols(from: symbols)]
        return coinMarketCapRequest(requestModel: .metadata, parameters: parameters, completion: completion)
    }
}
