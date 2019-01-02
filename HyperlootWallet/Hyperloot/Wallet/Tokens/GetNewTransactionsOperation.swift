//
//  InventoryUpdateOperation.swift
//  HyperlootWallet
//
//  Created by valery_vaskabovich on 12/29/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

class GetNewTransactionsOperation: HyperlootOperation {
    
    typealias Completion = ([HyperlootTransaction]) -> Void
    
    let token: HyperlootToken
    let walletAddress: String
    let lastProcessedTimeInterval: TimeInterval
    
    weak var blockscout: Blockscout?
    var completion: Completion
    
    required init(token: HyperlootToken, walletAddress: String, blockscout: Blockscout, lastProcessedTimeInterval: TimeInterval, completion: @escaping Completion) {
        self.token = token
        self.walletAddress = walletAddress
        self.lastProcessedTimeInterval = lastProcessedTimeInterval
        self.blockscout = blockscout
        self.completion = completion
    }
    
    override func main() {
        guard let blockscout = blockscout else { return }
        
        guard token.isERC721() else {
            completion([])
            return
        }
        
        run()
        getTransfers(page: 0, transactions: [], blockscout: blockscout) { [weak self] (transactions) in
            guard let strongSelf = self, strongSelf.isCancelled == false else { return }
            
            DispatchQueue.main.async {
                strongSelf.completion(transactions)
                strongSelf.done()
            }
        }
    }
    
    func getTransfers(page: Int, transactions: [HyperlootTransaction], blockscout: Blockscout, completion: @escaping Completion) {
        blockscout.tokenTransfers(address: walletAddress, contractAddress: token.contractAddress, page: page, completion: { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            guard let txs = response?.transactions, error == nil else {
                completion(transactions)
                return
            }
            
            var updatedTransactions = transactions
            var shouldContinue = true
            txs.forEach { (blockscoutTx) in
                guard let tx = HyperlootTransactionsTransformer.transaction(from: blockscoutTx) else {
                    return
                }
                
                guard tx.timestamp > strongSelf.lastProcessedTimeInterval else {
                    shouldContinue = false
                    return
                }
                
                updatedTransactions.append(tx)
            }
            
            if shouldContinue {
                strongSelf.getTransfers(page: page + 1, transactions: updatedTransactions, blockscout: blockscout, completion: completion)
            } else {
                completion(updatedTransactions)
            }
        })
    }
}
