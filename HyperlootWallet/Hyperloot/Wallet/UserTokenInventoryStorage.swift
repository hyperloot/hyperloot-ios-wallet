//
//  UserTokenInventoryStorage.swift
//  HyperlootWallet
//
//  Created by valery_vaskabovich on 12/28/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

class UserTokenInventoryStorage {
    
    struct Constants {
        static let inventoryFilename = "inventory.hl"
    }
    
    private lazy var inventoryFilePath: URL = {
        let docsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let docsDirectoryURL = URL(fileURLWithPath: docsDirectory)
        return docsDirectoryURL.appendingPathComponent(Constants.inventoryFilename)
    } ()
    
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
            
            return HyperlootTokenTransformer.tokenizedItem(from: token, tokenId: tokenId, attributes: HyperlootToken.Attributes(description: "", name: "", imageURL: ""))
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
        
        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.isInventoryLoaded = true
            
            guard let data = try? Data(contentsOf: strongSelf.inventoryFilePath) else {
                completion(false)
                return
            }
            
            do {
                let inventory = try JSONDecoder().decode(UserTokenInventoryStorage.Model.self, from: data)
                DispatchQueue.main.async {
                    strongSelf.inventory = inventory
                    completion(true)
                }
            } catch {
                print(error)
                completion(false)
            }
        }
    }
    
    func save(completion: @escaping (Bool) -> Void) {
        guard isInventoryLoaded else {
            completion(false)
            return
        }
        
        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let strongSelf = self else { return }
            
            guard let json = try? JSONEncoder().encode(strongSelf.inventory) else {
                completion(false)
                return
            }
            
            do {
                try json.write(to: strongSelf.inventoryFilePath, options: [.atomicWrite])
                DispatchQueue.main.async {
                    completion(true)
                }
            } catch {
                print(error)
                completion(false)
            }
        }
    }
}
