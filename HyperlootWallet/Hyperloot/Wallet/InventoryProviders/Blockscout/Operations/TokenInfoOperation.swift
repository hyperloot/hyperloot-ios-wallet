//
//  TokenInfoOperation.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import BigInt

class TokenInfoOperation: HyperlootOperation {
    
    let contractAddress: String
    let balance: String
    
    weak var storage: UserTokenInventoryStorage?
    weak var blockscout: Blockscout?
    
    required init(contractAddress: String, balance: String, blockscout: Blockscout, storage: UserTokenInventoryStorage) {
        self.contractAddress = contractAddress
        self.balance = balance
        self.blockscout = blockscout
        self.storage = storage
    }
    
    private func token(from response: BlockscoutGetTokenResponse?) -> HyperlootToken? {
        guard let tokenResponse = response?.token, let blockscout = blockscout else {
            return nil
        }
        return HyperlootTokenTransformer.token(from: tokenResponse, balance: balance, blockchain: blockscout.blockchain)
    }
    
    override func main() {
        guard let blockscout = blockscout, let storage = storage else {
            return
        }
        
        run()
        
        guard isCancelled == false else { return }
        
        storage.findToken(byAddress: contractAddress) { [weak self] (storedToken) in
            guard let strongSelf = self else { return }
            
            if let storedToken = storedToken {
                let token = HyperlootTokenTransformer.token(from: storedToken, balance: strongSelf.balance, blockchain: blockscout.blockchain)
                storage.replace(token: token) { [weak self] in
                    self?.done()
                }
            } else {
                blockscout.getToken(contractAddress: strongSelf.contractAddress, completion: { [weak self] (response, error) in
                    guard let strongSelf = self, strongSelf.isCancelled == false,
                        let token = strongSelf.token(from: response) else {
                            self?.done()
                            return
                    }
                    
                    storage.add(token: token) {
                        strongSelf.done()
                    }
                })
            }
        }
    }
}
