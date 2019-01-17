//
//  TokenManager.swift
//  HyperlootWallet
//
//  Created by valery_vaskabovich on 12/9/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import BigInt

class TokenInventoryManager {
    
    let blockscout: Blockscout
    
    lazy var tokensInfoOperationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    } ()
    
    lazy var formatter: EtherNumberFormatter = {
        let formatter = EtherNumberFormatter.full
        formatter.maximumFractionDigits = 4
        return formatter
    } ()
    
    lazy var inventory = UserTokenInventoryStorage()
    var blockscoutProvider: BlockscoutInventoryProvider?
    
    required init(environment: Blockscout.Environment) {
        self.blockscout = Blockscout(environment: environment)
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
