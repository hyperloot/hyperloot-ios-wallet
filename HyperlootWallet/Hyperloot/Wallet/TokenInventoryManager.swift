//
//  TokenManager.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import BigInt
import TrustCore
import Result

class TokenInventoryManager {
    
    let blockscout: Blockscout
    let openSea: OpenSea
    let config: HyperlootConfig
    let priceDiscovery: TokenPriceDiscovery
    
    lazy var tokensInfoOperationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    } ()
        
    lazy var inventory = UserTokenInventoryStorage()
    var blockscoutProvider: BlockscoutInventoryProvider?
    var openSeaProvider: OpenSeaInventoryProvider?
    
    private var tokenSenders: [String: HyperlootTokenItemSender] = [:]
    
    required init(config: HyperlootConfig) {
        self.blockscout = Blockscout(environment: config.blockscout)
        self.openSea = OpenSea(environment: config.openSea, apiKey: config.openSeaAPIKey)
        self.priceDiscovery = TokenPriceDiscovery(config: config)
        self.config = config
    }
    
    func updateInventory(address: String, completion: @escaping ([HyperlootToken]) -> Void) {
        blockscoutProvider = BlockscoutInventoryProvider(blockscout: blockscout, storage: inventory, walletAddress: address)
        openSeaProvider = OpenSeaInventoryProvider(openSea: openSea, walletAddress: address)
        
        inventory.loadInventory { [weak self] (loaded) in
            
            let group = DispatchGroup()
            
            var blockscoutTokens: [HyperlootToken] = []
            var openSeaTokens: [HyperlootToken] = []
                        
            group.enter()
            self?.blockscoutProvider?.getInventoryItems { (tokens) in
                blockscoutTokens = tokens
                self?.blockscoutProvider = nil
                group.leave()
            }
            
            group.enter()
            self?.openSeaProvider?.getInventoryItems(completion: { (tokens) in
                openSeaTokens = tokens
                self?.openSeaProvider = nil
                group.leave()
            })

            group.notify(queue: DispatchQueue.main, execute: {
                
                func findIndex(openSeaToken: HyperlootToken) -> Int? {
                    return blockscoutTokens.firstIndex(where: { (token) -> Bool in
                        switch (token.type, openSeaToken.type) {
                        case (.ether(_), .ether(_)):
                            return false
                        case (.erc20(_), .erc20(_)):
                            return token.contractAddress == openSeaToken.contractAddress
                        case (.erc721(let tokenId, _, _), .erc721(let openSeaTokenId, _, _)):
                            return token.contractAddress == openSeaToken.contractAddress && tokenId == openSeaTokenId
                        default:
                            return false
                        }
                    })
                }
                
                openSeaTokens.forEach { (openSeaToken) in
                    if let index = findIndex(openSeaToken: openSeaToken) {
                        blockscoutTokens[index] = openSeaToken
                    } else {
                        blockscoutTokens.append(openSeaToken)
                    }
                }
                completion(blockscoutTokens)
            })
        }
    }
    
    func send(token: HyperlootToken, from: String, to: String, value: HyperlootTokenItemSender.SendingValue, transactionSigner: HyperlootTransactionSigning, completion: @escaping (Result<HyperlootTransaction, HyperlootTransactionSendError>) -> Void) {
        guard let from = Address(string: from), let to = Address(string: to) else { return }
        
        func add(_ tokenSender: HyperlootTokenItemSender) {
            tokenSenders[tokenSender.uniqueIdentifier] = tokenSender
        }
        
        func remove(_ tokenSender: HyperlootTokenItemSender) {
            tokenSenders.removeValue(forKey: tokenSender.uniqueIdentifier)
        }
        
        let tokenSender = HyperlootTokenItemSender(from: from, to: to, token: token, sendingValue: value, config: config, transactionSigner: transactionSigner)
        add(tokenSender)
        tokenSender.send { (result) in
            completion(result)
            remove(tokenSender)
        }
    }
    
    func getTransactions(address: String, page: Int, limitPerPage: Int = 500, transactionType: HyperlootTransactionType, completion: @escaping ([HyperlootTransaction]) -> Void) {
        switch transactionType {
        case .transactions:
            blockscout.transactions(address: address, pagination: (page: page, offset: limitPerPage)) { [weak self] (response, error) in
                self?.processTransactions(response: response, completion: completion)
            }
        case .tokens(contractAddress: let contractAddress):
            blockscout.tokenTransfers(address: address, contractAddress: contractAddress, pagination: (page: page, offset: limitPerPage)) { [weak self] (response, error) in
                self?.processTransactions(response: response, completion: completion)
            }
        }
    }
    
    private func processTransactions(response: BlockscoutTransactionListResponse?, completion: @escaping ([HyperlootTransaction]) -> Void) {
        guard let transactions = response?.transactions else {
            completion([])
            return
        }
        
        var hyperlootTransactions: [HyperlootTransaction] = []
        transactions.forEach { (transaction) in
            guard let tx = HyperlootTransactionsTransformer.transaction(from: transaction) else { return }
            hyperlootTransactions.append(tx)
        }
        DispatchQueue.main.async {
            completion(hyperlootTransactions)
        }
    }
}
