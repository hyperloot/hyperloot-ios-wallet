//
//  TokenItemBalanceOperation.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

class TokenItemBalanceOperation: HyperlootOperation {
    
    typealias Completion = ([HyperlootTransaction]) -> Void
    
    struct Constants {
        static let maxTransactionsPerPage = 500
    }
    
    let contractAddress: String
    let walletAddress: String
    let storage: UserTokenInventoryStorage
    
    weak var blockscout: Blockscout?
    
    var lastProcessedTimestamp: TimeInterval
    
    required init(contractAddress: String, walletAddress: String, blockscout: Blockscout, storage: UserTokenInventoryStorage) {
        self.contractAddress = contractAddress
        self.walletAddress = walletAddress
        self.storage = storage
        self.blockscout = blockscout
        
        self.lastProcessedTimestamp = storage.lastProcessedTimestamp(contractAddress: contractAddress)
    }
    
    override func main() {
        guard let blockscout = blockscout else { return }
        
        run()
        
        guard let token = storage.findToken(byAddress: contractAddress),
            token.isERC721() else {
                done()
                return
        }
        
        getTransfers(page: 0, transactions: [], blockscout: blockscout) { [weak self] (transactions) in
            guard let strongSelf = self, strongSelf.isCancelled == false else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.storage.updateTokenizedItems(contractAddress: strongSelf.contractAddress,
                                                        walletAddress: strongSelf.walletAddress,
                                                        transactions: transactions)
                strongSelf.done()
            }
        }
    }
    
    func getTransfers(page: Int, transactions: [HyperlootTransaction], blockscout: Blockscout, completion: @escaping Completion) {
        print("Getting transfers for page: \(page)")
        blockscout.tokenTransfers(address: walletAddress, contractAddress: contractAddress, pagination: (page: page, offset: Constants.maxTransactionsPerPage), completion: { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            guard let txs = response?.transactions, error == nil else {
                completion(transactions)
                return
            }
            
            var updatedTransactions = transactions
            var shouldContinue = txs.count >= Constants.maxTransactionsPerPage
            
            txs.forEach { (blockscoutTx) in
                guard let tx = HyperlootTransactionsTransformer.transaction(from: blockscoutTx) else {
                    return
                }
                
                guard tx.timestamp > strongSelf.lastProcessedTimestamp else {
                    shouldContinue = false
                    return
                }
                
                updatedTransactions.append(tx)
            }
            
            if let lastTx = updatedTransactions.first {
                strongSelf.lastProcessedTimestamp = lastTx.timestamp
            }
            
            if shouldContinue {
                strongSelf.getTransfers(page: page + 1, transactions: updatedTransactions, blockscout: blockscout, completion: completion)
            } else {
                completion(updatedTransactions)
            }
        })
    }
}
