//
//  BlockscoutInventoryProvider.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation
import BigInt

class BlockscoutInventoryProvider: TokenInventoryProviding {
    
    typealias Completion = ([HyperlootToken]) -> Void
    
    lazy var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 5
        return queue
    } ()
    
    lazy var formatter: EtherNumberFormatter = {
        let formatter = EtherNumberFormatter.full
        formatter.maximumFractionDigits = 4
        return formatter
    } ()

    weak var blockscout: Blockscout?
    let storage: UserTokenInventoryStorage
    let walletAddress: String
    
    lazy var mainNetBlockscout: Blockscout = Blockscout(environment: .mainnet)
    
    deinit {
        operationQueue.cancelAllOperations()
    }
    
    init(blockscout: Blockscout, storage: UserTokenInventoryStorage, walletAddress: String) {
        self.blockscout = blockscout
        self.storage = storage
        self.walletAddress = walletAddress
    }
    
    func getInventoryItems(completion: @escaping Completion) {
        
        var tokens: [HyperlootToken] = []
        
        getBalance(address: walletAddress) { [weak self] (token) in
            guard let strongSelf = self else { return }
            tokens.append(token)
            strongSelf.getTokens(address: strongSelf.walletAddress) { (tokenlist) in
                tokens.append(contentsOf: tokenlist)
                completion(tokens)
            }
        }
    }
    
    private func getBalance(address: String, completion: @escaping (HyperlootToken) -> Void) {
        guard let blockscout = blockscout else { return }
        blockscout.balance(address: address) { [weak self] (response, error) in
            guard let balance = response?.balance,
                let amount = BigInt(balance),
                let stringValue = self?.formatter.string(from: amount, decimals: TokenContracts.ethereum.decimals) else {
                    completion(HyperlootToken.ether(amount: "0", blockchain: blockscout.blockchain))
                    return
            }
            
            let token = HyperlootToken.ether(amount: stringValue, blockchain: blockscout.blockchain)
            self?.storage.replace(token: token) {
                completion(token)
            }
        }
    }
    
    private func getTokens(address: String, completion: @escaping Completion) {
        guard let blockscout = blockscout else { return }
        blockscout.getTokenList(address: address) { [weak self] (response, error) in
            self?.process(tokens: response?.tokens ?? [], completion: completion)
        }
    }
    
    private func process(tokens: [BlockscoutTokenListResponse.Token], completion: @escaping Completion) {
        var operations: [Operation] = []
        
        tokens.forEach { (token) in
            guard let address = token.contractAddress, let balance = token.balance, let blockscout = blockscout else { return }
            let tokenInfoOperation = TokenInfoOperation(contractAddress: address, balance: balance, blockscout: blockscout, storage: storage)
            let tokenItemBalanceOperation = TokenItemBalanceOperation(contractAddress: address, walletAddress: walletAddress, blockscout: blockscout, storage: storage)
            tokenItemBalanceOperation.addDependency(tokenInfoOperation)
            operations.append(contentsOf: [tokenInfoOperation, tokenItemBalanceOperation])
        }
        
        operations.append(contentsOf: defaultTokenOperations(userTokens: tokens))
        print("*** OPERATIONS: \(operations.count)")
        
        let completionOperation = BlockOperation { [weak self] in
            self?.storage.save(completion: { (_) in
                completion(self?.storage.allTokens ?? [])
            })
        }
        operations.forEach { completionOperation.addDependency($0) }
        operations.append(completionOperation)
        
        operationQueue.addOperations(operations, waitUntilFinished: false)
    }
    
    private func defaultTokenOperations(userTokens: [BlockscoutTokenListResponse.Token]) -> [Operation] {
        var defaultTokens = HyperlootToken.defaultTokens(blockchain: .mainnet)
        defaultTokens.removeAll { (token) -> Bool in
            return userTokens.contains(where: { (response) -> Bool in
                response.contractAddress == token.contractAddress
            })
        }
        
        return defaultTokens.map { TokenInfoOperation(contractAddress: $0.contractAddress,
                                                      balance: "0",
                                                      blockscout: mainNetBlockscout,
                                                      storage: storage) }
        
    }
}
