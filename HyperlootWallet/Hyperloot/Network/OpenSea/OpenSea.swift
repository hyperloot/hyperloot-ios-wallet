//
//  OpenSea.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

class OpenSea: HTTPService {
    
    enum Environment: String {
        case mainnet = "https://api.opensea.io/api/v1/"
        case rinkeby = "https://rinkeby-api.opensea.io/api/v1/"
    }
    
    let environment: Environment
    let apiKey: String
    
    var blockchain: Blockchain {
        switch environment {
        case .mainnet: return .mainnet
        case .rinkeby: return .rinkeby
        }
    }
    
    required init(environment: Environment, apiKey: String) {
        let host = URL(string: environment.rawValue)!
        self.apiKey = apiKey
        self.environment = environment
        super.init(host: host)
    }
    
    enum OpenSeaRequest: String {
        case assets = "assets"
    }
    
    private func validate(object: Any?) -> Error? {
        return nil
    }
    
    func openSeaRequest<T>(requestModel: OpenSeaRequest, parameters: Parameters? = nil, completion: @escaping (T?, Error?) -> Void) -> DataRequest where T : BaseMappable {
        let headers: HTTPHeaders = ["X-API-KEY": apiKey]
        return request(requestModel.rawValue, keyPath: nil, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers, validation: { [weak self] (object) -> Error? in
            return self?.validate(object: object)
            }, objectCompletion: completion)
    }
    
    enum OrderBy: String {
        case lastSale = "last_sale"
        case numberOfSales = "num_sales"
        case tokenId = "token_id"
        case listingDate = "listing_date"
        case currentPrice = "current_price"
        case currentEscrowPrice = "current_escrow_price"
        case topBid = "top_bid"
        case saleDate = "sale_date"
        case saleCount = "sale_count"
        case visitorCount = "visitor_count"
        case salePrice = "sale_price"
        case totalPrice = "total_price"
    }
    
    enum OrderDirection: String {
        case ascending = "asc"
        case descending = "desc"
    }
    
    func assets(ownerAddress: String, orderBy: OrderBy = .listingDate, orderDirection: OrderDirection = .descending, completion: @escaping (OpenSeaAssetsResponse?, Error?) -> Void) -> Cancelable {
        let parameters: Parameters = [ "owner": ownerAddress,
                                       "order_by": orderBy.rawValue,
                                       "order_direction": orderDirection.rawValue]
        return openSeaRequest(requestModel: .assets, parameters: parameters, completion: completion)
    }
 }
