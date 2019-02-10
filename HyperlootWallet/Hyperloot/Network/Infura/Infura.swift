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
    
    let blockchain: Blockchain
    
    init(environment: Blockchain, apiKey: String) {
        let infuraEnv = Infura.Environment(blockchain: environment)
        let hostString = infuraEnv.rawValue.appending(apiKey)
        self.blockchain = environment
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
        if let errorMessage = response.error?.message {
            return infuraError(message: errorMessage)
        }
        
        return nil
    }
    
    enum JSONRPCRequest: String {
        case getBalance = "eth_getBalance"
        case getTransactionCount = "eth_getTransactionCount"
        case estimateGas = "eth_estimateGas"
        case gasPrice = "eth_gasPrice"
        case sendRawTransaction = "eth_sendRawTransaction"
    }
    
    func request<T>(request jsonrpcRequest: JSONRPCRequest, parameters: [Any] = [], completion: @escaping (T?, Error?) -> Void) -> DataRequest where T : BaseMappable {
        let jsonRPCRequestParams: [String: Any] = ["jsonrpc": "2.0",
                                                   "method": jsonrpcRequest.rawValue,
                                                   "params": parameters,
                                                   "id": blockchain.rawValue]
        return request("", keyPath: nil, method: .post, parameters: jsonRPCRequestParams, encoding: JSONEncoding.default, headers: nil, validation: { [weak self] (object) -> Error? in
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
    func getBalance(address: String, blockNumber: BlockNumber, completion: @escaping (EthGetBalanceResponse?, Error?) -> Void) -> Cancelable {
        return request(request: .getBalance, parameters: [address, blockNumber.rawValue], completion: completion)
    }
    
    @discardableResult
    func getTransactionCount(address: String, blockNumber: BlockNumber, completion: @escaping (EthGetTransactionCountResponse?, Error?) -> Void) -> Cancelable {
        return request(request: .getTransactionCount, parameters: [address, blockNumber.rawValue], completion: completion)
    }
    
    @discardableResult
    func estimateGas(from: String, to: String, gasLimit: String?, gasPrice: String?, value: String?, data: String?, completion: @escaping (EthEstimateGasResponse?, Error?) -> Void) -> Cancelable {
        var params: [String: String] = ["from": from,
                                        "to": to]
        if let gasLimit = gasLimit { params["gasLimit"] = gasLimit }
        if let gasPrice = gasPrice { params["gasPrice"] = gasPrice }
        if let value = value { params["value"] = value }
        if let data = data { params["data"] = data }

        return request(request: .estimateGas, parameters: [params], completion: completion)
    }
    
    @discardableResult
    func gasPrice(completion: @escaping (EthGasPriceResponse?, Error?) -> Void) -> Cancelable {
        return request(request: .gasPrice, completion: completion)
    }
    
    @discardableResult
    func sendRawTransaction(signedTransactionDataInHex: String, completion: @escaping (EthSendRawTransactionResponse?, Error?) -> Void) -> Cancelable {
        let params: [String] = [signedTransactionDataInHex]
        return request(request: .sendRawTransaction, parameters: params, completion: completion)
    }
}
