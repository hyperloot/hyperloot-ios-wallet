//
//  UserTokenInventoryStorage.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

class UserTokenInventoryStorage {
    
    struct Constants {
        static let inventoryFilename = "inventory.hl"
    }
    
    private lazy var inventoryFilePath = URL.documentsPath(filename: Constants.inventoryFilename)
    
    private struct Model: Codable {
        typealias TokenContractAddress = String
        
        struct TokenizedItem: Codable {
            var lastProcessedTimestamp: TimeInterval
            var tokens: [HyperlootToken]
        }

        var tokens: [HyperlootToken]
        var tokenizedItems: [TokenContractAddress: TokenizedItem]
    }
    
    private var inventory: Model = Model(tokens: [], tokenizedItems: [:])
    private var isInventoryLoaded: Bool = false
    private lazy var dataSerializer = HyperlootDataSerializer(path: self.inventoryFilePath)
    
    var allTokens: [HyperlootToken] {
        var allTokens: [HyperlootToken] = []
        allTokens.append(contentsOf: inventory.tokens)
        allTokens.append(contentsOf: inventory.tokenizedItems.flatMap { $0.value.tokens })
        return allTokens
    }
    
    func findToken(byAddress contractAddress: String) -> HyperlootToken? {
        return inventory.tokens.filter { $0.contractAddress == contractAddress }.first
    }
    
    func replace(token: HyperlootToken, completion: @escaping () -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            
            if let prevToken = strongSelf.findToken(byAddress: token.contractAddress),
                let index = (strongSelf.inventory.tokens.firstIndex { (t) -> Bool in return t.contractAddress == prevToken.contractAddress }) {
                strongSelf.inventory.tokens.remove(at: index)
                strongSelf.inventory.tokens.insert(token, at: index)
                completion()
            } else {
                strongSelf.add(token: token, completion: completion)
            }
        }
    }
    
    func add(token: HyperlootToken, completion: @escaping () -> Void) {
        DispatchQueue.main.async { [weak self] in
            self?.inventory.tokens.append(token)
            completion()
        }
    }
    
    func shouldLoadTokenInfo(address: String) -> Bool {
        return findToken(byAddress: address) == nil
    }
    
    func lastProcessedTimestamp(contractAddress: String) -> TimeInterval {
        return inventory.tokenizedItems[contractAddress]?.lastProcessedTimestamp ?? 0
    }
    
    func updateTokenizedItems(contractAddress: String, walletAddress: String, transactions: [HyperlootTransaction]) {
        guard let token = findToken(byAddress: contractAddress),
            let lastTransaction = transactions.first else {
                return
        }
        
        var tokenizedItem = inventory.tokenizedItems[contractAddress] ?? Model.TokenizedItem(lastProcessedTimestamp: 0, tokens: [])

        typealias TokenID = String
        let tokensToRemove: [TokenID] = transactions.compactMap { (tx) in
            guard TokenFormatter.isTo(walletAddress: walletAddress, transaction: tx) == false,
                case .uniqueToken(tokenId: let tokenId) = tx.value else {
                return nil
            }
            return tokenId
        }
        
        let tokensToAdd: [HyperlootToken] = transactions.compactMap { (tx) in
            guard case .uniqueToken(tokenId: let tokenId) = tx.value,
                tokensToRemove.contains(tokenId) == false else {
                return nil
            }
            
            return HyperlootTokenTransformer.tokenizedItem(from: token, tokenId: tokenId, attributes: nil)
        }
        
        tokenizedItem.tokens.removeAll { (t) -> Bool in
            guard case .erc721(tokenId: let tokenId, totalCount: _, attributes: _) = t.type else { return false }
            return tokensToRemove.contains(tokenId)
        }
        tokenizedItem.tokens.append(contentsOf: tokensToAdd)
        
        tokenizedItem.lastProcessedTimestamp = lastTransaction.timestamp
        
        inventory.tokenizedItems[contractAddress] = tokenizedItem
    }
    
    // MARK: - Database methods
        
    func loadInventory(completion: @escaping (Bool) -> Void) {
        guard isInventoryLoaded == false else {
            completion(true)
            return
        }
        
        dataSerializer.loadObject { [weak self] (inventory: Model?) in
            guard let inventory = inventory else {
                completion(false)
                return
            }
            self?.inventory = inventory
            self?.isInventoryLoaded = true
            completion(true)
        }
    }
    
    func save(completion: @escaping (Bool) -> Void) {
        guard isInventoryLoaded else {
            completion(false)
            return
        }
        
        dataSerializer.save(object: self.inventory, completion: completion)
    }
}
