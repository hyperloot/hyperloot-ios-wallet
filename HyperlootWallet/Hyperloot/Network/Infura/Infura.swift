//
//  Infura.swift
//  HyperlootWallet
//
//  Created by valery_vaskabovich on 1/26/19.
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

class Infura: HTTPService {
    
    enum Environment: String {
        case mainnet = "https://mainnet.infura.io/v3/"
        case ropsten = "https://ropsten.infura.io/v3/"
        case rinkeby = "https://rinkeby.infura.io/v3/"
        case kovan = "https://kovan.infura.io/v3/"
        
        init(blockchain: Blockchain) {
            switch blockchain {
            case .mainnet: self = .mainnet
            case .ropsten: self = .ropsten
            case .rinkeby: self = .rinkeby
            case .kovan: self = .kovan
            }
        }
    }
    
    init(environment: Blockchain, apiKey: String) {
        let infuraEnv = Infura.Environment(blockchain: environment)
        let hostString = infuraEnv.rawValue.appending(apiKey)
        super.init(host: URL(string: hostString)!)
    }
    
    // MARK: - Common
    
    private func infuraError(message: String) -> Error {
        return NSError(domain: "com.hyperloot.infura.jsonrpc", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey: message])
    }
    
    private func validate(object: Any?) -> Error? {
        guard let response = Mapper<InfuraBaseResponse>().map(JSONObject: object),
            response.result != nil, response.chainId != nil else {
                return infuraError(message: "Response is not valid")
        }
        
        return infuraError(message: "There was an error during fetching data from Ethereum blockchain")
    }
    
    enum JSONRPCRequest: String {
        case getTransactionCount = "eth_getTransactionCount"
        case estimateGas = "eth_estimateGas"
        case gasPrice = "eth_gasPrice"
    }
    
    func request<T>(request jsonrpcRequest: JSONRPCRequest, parameters: [Any] = [], completion: @escaping (T?, Error?) -> Void) -> DataRequest where T : BaseMappable {
        return request(jsonrpcRequest.rawValue, keyPath: nil, method: .get, parameters: ["params": parameters], encoding: URLEncoding.default, headers: nil, validation: { [weak self] (object) -> Error? in
            return self?.validate(object: object)
        }, objectCompletion: completion)
    }
    
    // MARK: JSON RPC methods
    
    enum BlockNumber: String {
        case latest = "latest"
        case earliest = "earliest"
        case pending = "pending"
    }
    
    @discardableResult
    func getTransactionCount(address: String, blockNumber: BlockNumber, completion: @escaping (EthGetTransactionCountResponse?, Error?) -> Void) -> Cancelable {
        return request(request: .getTransactionCount, parameters: [address, blockNumber.rawValue], completion: completion)
    }
    
    @discardableResult
    func estimateGas(from: String, to: String, gasLimit: String?, gasPrice: String?, value: String?, data: String?, completion: @escaping (EthEstimateGasResponse?, Error?) -> Void) -> Cancelable {
        let params: [String] = [from, to, gasLimit, gasPrice, value, data].compactMap { $0 }
        return request(request: .estimateGas, parameters: params, completion: completion)
    }
    
    @discardableResult
    func gasPrice(completion: @escaping (EthGasPriceResponse?, Error?) -> Void) -> Cancelable {
        return request(request: .gasPrice, completion: completion)
    }
}
