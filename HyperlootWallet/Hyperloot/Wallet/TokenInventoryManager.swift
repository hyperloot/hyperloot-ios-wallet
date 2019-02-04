//
//  TokenManager.swift
//  HyperlootWallet
//
//  Created by valery_vaskabovich on 12/9/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import BigInt
import TrustCore
import Result

class TokenInventoryManager {
    
    let blockscout: Blockscout
    let config: HyperlootConfig
    
    lazy var tokensInfoOperationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    } ()
        
    lazy var inventory = UserTokenInventoryStorage()
    var blockscoutProvider: BlockscoutInventoryProvider?
    
    private var tokenSenders: [String: TokenItemSender] = [:]
    
    required init(config: HyperlootConfig) {
        self.blockscout = Blockscout(environment: config.blockscout)
        self.config = config
    }
    
    func updateInventory(address: String, completion: @escaping ([HyperlootToken]) -> Void) {
        blockscoutProvider = BlockscoutInventoryProvider(blockscout: blockscout, storage: inventory, walletAddress: address)
        
        inventory.loadInventory { [weak self] (loaded) in
            self?.blockscoutProvider?.getInventoryItems { (tokens) in
                completion(tokens)
                self?.blockscoutProvider = nil
            }
        }
    }
    
    func send(token: HyperlootToken, from: String, to: String, transactionSigner: HyperlootTransactionSigning, completion: @escaping (Result<HyperlootTransaction, SendError>) -> Void) {
        guard let from = Address(string: from), let to = Address(string: to) else { return }
        
        func add(_ tokenSender: TokenItemSender) {
            tokenSenders[tokenSender.uniqueIdentifier] = tokenSender
        }
        
        func remove(_ tokenSender: TokenItemSender) {
            tokenSenders.removeValue(forKey: tokenSender.uniqueIdentifier)
        }
        
        let tokenSender = TokenItemSender(from: from, to: to, token: token, config: config, transactionSigner: transactionSigner)
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
