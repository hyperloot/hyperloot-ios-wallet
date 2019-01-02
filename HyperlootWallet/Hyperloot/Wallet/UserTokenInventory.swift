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
        return URL(fileURLWithPath: docsDirectory + Constants.inventoryFilename)
    } ()
    
    private struct Model: Codable {
        typealias TokenContractAddress = String
        
        struct TokenTransactions: Codable {
            var lastProcessedTimestamp: TimeInterval
            var transactions: [HyperlootTransaction]
        }

        var tokens: [HyperlootToken]
        var transactions: [TokenContractAddress: TokenTransactions]
    }
    
    private var inventory: Model = Model(tokens: [], transactions: [:])
    private var isInventoryLoaded: Bool = false
    
    func findToken(byAddress contractAddress: String) -> HyperlootToken? {
        return inventory.tokens.filter { $0.contractAddress == contractAddress }.first
    }
    
    func hasInformation(token: HyperlootToken) -> Bool {
        return findToken(byAddress: token.contractAddress) != nil
    }
        
    func loadInventory(completion: @escaping (Bool) -> Void) {
        guard isInventoryLoaded == false else {
            completion(true)
            return
        }
        
        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let strongSelf = self else { return }
            
            guard let data = try? Data(contentsOf: strongSelf.inventoryFilePath),
                let inventory = try? JSONDecoder().decode(UserTokenInventoryStorage.Model.self, from: data) else {
                    completion(false)
                    return
            }
            
            DispatchQueue.main.async {
                self?.isInventoryLoaded = true
                self?.inventory = inventory
                completion(true)
            }
        }
    }
    
    func save(completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let strongSelf = self else { return }
            
            guard let json = try? JSONEncoder().encode(strongSelf.inventory) else {
                completion(false)
                return
            }
            try? json.write(to: strongSelf.inventoryFilePath, options: [.atomicWrite])
            DispatchQueue.main.async {
                completion(true)
            }
        }
    }
}
