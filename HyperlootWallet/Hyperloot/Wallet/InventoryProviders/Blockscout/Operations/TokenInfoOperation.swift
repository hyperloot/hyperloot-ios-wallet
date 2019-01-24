//
//  TokenInfoOperation.swift
//  HyperlootWallet
//
//  Created by valery_vaskabovich on 12/12/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import BigInt

class TokenInfoOperation: HyperlootOperation {
    
    let contractAddress: String
    let balance: String
    let storage: UserTokenInventoryStorage
    
    weak var blockscout: Blockscout?
    
    required init(contractAddress: String, balance: String, blockscout: Blockscout, storage: UserTokenInventoryStorage) {
        self.contractAddress = contractAddress
        self.balance = balance
        self.blockscout = blockscout
        self.storage = storage
    }
    
    private func token(from response: BlockscoutGetTokenResponse?) -> HyperlootToken? {
        guard let tokenResponse = response?.token else {
            return nil
        }
        return HyperlootTokenTransformer.token(from: tokenResponse, balance: balance)
    }
    
    override func main() {
        guard let blockscout = blockscout else {
            return
        }
        
        run()
        if let storedToken = storage.findToken(byAddress: contractAddress) {
            let token = HyperlootTokenTransformer.token(from: storedToken, balance: balance)
            storage.replace(token: token) { [weak self] in
                self?.done()
            }
        } else {
            blockscout.getToken(contractAddress: contractAddress, completion: { [weak self] (response, error) in
                guard let strongSelf = self, strongSelf.isCancelled == false,
                    let token = strongSelf.token(from: response) else {
                        self?.done()
                        return
                }
                
                strongSelf.storage.add(token: token) {
                    strongSelf.done()
                }
            })
        }
    }
}
