//
//  Blockscout.swift
//  HyperlootWallet
//
//  Created by valery_vaskabovich on 12/3/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

class Blockscout: HTTPService {
    
    enum Environment: String {
        case mainnet = "https://blockscout.com/eth/mainnet/api"
        case ropsten = "https://blockscout.com/eth/ropsten/api"
    }
    
    typealias RequestParameters = [String: Any]
    
    struct RequestModel {
        
        enum Modules: String {
            case account = "account"
            case token = "token"
            case transaction = "transaction"
        }
        
        enum Actions: String {
            case balance = "balance"
            case transactionsList = "txlist"
            case tokenTransactions = "tokentx"
            case tokenBalance = "tokenbalance"
            case tokenList = "tokenList"
            case tokenDetails = "getToken"
            case transactionInfo = "gettxinfo"
        }
        
        let module: Modules
        let action: Actions
        let parameters: RequestParameters
        
        func requestParameters() -> RequestParameters {
            var dict: RequestParameters = ["module": module.rawValue, "action": action.rawValue]
            dict.merge(with: parameters)
            return dict
        }
    }
    
    let environment: Environment
    
    var blockchain: Blockchain {
        switch environment {
        case .mainnet: return .mainnet
        case .ropsten: return .ropsten
        }
    }
    
    required init(environment: Environment) {
        let host = URL(string: environment.rawValue)!
        self.environment = environment
        super.init(host: host)
    }
    
    private func blockscoutError(message: String) -> Error {
        return NSError(domain: "com.hyperloot.blockscout", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey: message])
    }
    
    private func validate(object: Any?) -> Error? {
        guard let response = Mapper<BlockscoutBaseResponse>().map(JSONObject: object),
            let status = response.status, let message = response.message else {
            return blockscoutError(message: "Response is not valid")
        }
        
        guard status == 0 else {
            return nil
        }
        
        return blockscoutError(message: message)
    }
    
    func request<T>(requestModel: RequestModel, completion: @escaping (T?, Error?) -> Void) -> DataRequest where T : BaseMappable {
        return request("", keyPath: nil, method: .post, parameters: requestModel.requestParameters(), encoding: URLEncoding.default, headers: nil, validation: { [weak self] (object) -> Error? in
            return self?.validate(object: object)
        }, objectCompletion: completion)
    }
    
    @discardableResult
    func balance(address: String, completion: @escaping (BlockscoutBalanceResponse?, Error?) -> Void) -> Cancelable {
        let model = RequestModel(module: .account, action: .balance, parameters: ["address": address])
        return request(requestModel: model, completion: completion)
    }
    
    @discardableResult
    func getTokenList(address: String, completion: @escaping (BlockscoutTokenListResponse?, Error?) -> Void) -> Cancelable {
        let model = RequestModel(module: .account, action: .tokenList, parameters: ["address": address])
        return request(requestModel: model, completion: completion)
    }
    
    @discardableResult
    func getToken(contractAddress: String, completion: @escaping (BlockscoutGetTokenResponse?, Error?) -> Void) -> Cancelable {
        let model = RequestModel(module: .token, action: .tokenDetails, parameters: ["contractaddress": contractAddress])
        return request(requestModel: model, completion: completion)
    }

    enum TransactionsSortOptions: String {
        case ascending = "asc"
        case descending = "desc"
    }
    /// This API call returns all transactions for the account (not tokens)
    ///
    /// - Parameters:
    ///   - address: Account address
    ///   - page: Page number for transactions
    ///   - completion: Completion
    /// - Returns: Cancelable operation
    @discardableResult
    func transactions(address: String, pagination: (page: Int, offset: Int)? = nil, sort: TransactionsSortOptions = .descending, completion: @escaping (BlockscoutTransactionListResponse?, Error?) -> Void) -> Cancelable {
        var parameters: RequestParameters = ["address": address, "sort": sort.rawValue]
        if let pagination = pagination {
            parameters["page"] = pagination.page
            parameters["offset"] = pagination.offset
        }
        let model = RequestModel(module: .account, action: .transactionsList, parameters: parameters)
        return request(requestModel: model, completion: completion)
    }
    
    
    /// This API call returns all token transfers (rather than ether) for the account or for the account with contract address
    ///
    /// - Parameters:
    ///   - address: Account address
    ///   - contractAddress: Contract address (optional) to get token transfers
    ///   - page: Page number for transactions
    ///   - completion: Completion block
    /// - Returns: Cancelable operation
    @discardableResult
    func tokenTransfers(address: String, contractAddress: String? = nil, pagination: (page: Int, offset: Int)? = nil, sort: TransactionsSortOptions = .descending, completion: @escaping (BlockscoutTransactionListResponse?, Error?) -> Void) -> Cancelable {
        var parameters: RequestParameters = ["address": address, "sort": sort.rawValue]
        if let contractAddress = contractAddress {
            parameters["contractaddress"] = contractAddress
        }
        if let pagination = pagination {
            parameters["page"] = pagination.page
            parameters["offset"] = pagination.offset
        }
        let model = RequestModel(module: .account, action: .tokenTransactions, parameters: parameters)
        return request(requestModel: model, completion: completion)
    }

}
