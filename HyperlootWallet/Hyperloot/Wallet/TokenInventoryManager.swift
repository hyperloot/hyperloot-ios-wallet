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
    
    required init(environment: Blockscout.Environment) {
        self.blockscout = Blockscout(environment: environment)
    }
    
    func updateInventory(address: String) {
        
        inventory.loadInventory { [weak self] (loaded) in
            guard loaded == true else {
                return
            }
            
            self?.getBalance(address: address) { (token) in
                self?.getTokens(address: address, completion: { (tokens) in
                    
                })
            }
        }
    }
    
    func getTokens(address: String, completion: @escaping ([HyperlootToken]) -> Void) {
        blockscout.getTokenList(address: address) { [weak self] (response, error) in
            self?.getTokensInformation(list: response, completion: completion)
        }
    }
    
    func getBalance(address: String, completion: @escaping (HyperlootToken) -> Void) {
        blockscout.balance(address: address) { [weak self] (response, error) in
            guard let balance = response?.balance,
                let amount = BigInt(balance),
                let stringValue = self?.formatter.string(from: amount, decimals: TokenConstants.Ethereum.ethereumDecimals) else {
                completion(HyperlootToken.ether(amount: "0"))
                return
            }
            
            completion(HyperlootToken.ether(amount: stringValue))
        }
    }
        
    func getTransactions(address: String, page: Int, transactionType: HyperlootTransactionType, completion: @escaping ([HyperlootTransaction]) -> Void) {
        switch transactionType {
        case .transactions:
            blockscout.transactions(address: address, page: page) { [weak self] (response, error) in
                self?.processTransactions(response: response, completion: completion)
            }
        case .tokens(contractAddress: let contractAddress):
            blockscout.tokenTransfers(address: address, contractAddress: contractAddress, page: page) { [weak self] (response, error) in
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
    
    private func getTokensInformation(list: BlockscoutTokenListResponse?, completion: @escaping ([HyperlootToken]) -> Void) {
        guard let tokens = list?.tokens else {
            completion([])
            return
        }
        
        var hyperlootTokens: [HyperlootToken] = []
        
        tokens.forEach {
            guard let address = $0.contractAddress, let balance = $0.balance else { return }
            
            let operation = TokenInfoOperation(contractAddress: address, balance: balance, blockscout: blockscout) { token in
                DispatchQueue.main.async {
                    guard let token = token else { return }
                    hyperlootTokens.append(token)
                }
            }
            tokensInfoOperationQueue.addOperation(operation)
        }
        
        tokensInfoOperationQueue.onCompletion {
            completion(hyperlootTokens)
        }
    }
}
