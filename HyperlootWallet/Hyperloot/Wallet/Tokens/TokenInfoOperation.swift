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
    
    typealias Completion = (HyperlootToken?) -> Void
    
    let contractAddress: String
    let balance: String
    
    weak var blockscout: Blockscout?
    var completion: Completion
    
    required init(contractAddress: String, balance: String, blockscout: Blockscout, completion: @escaping Completion) {
        self.contractAddress = contractAddress
        self.balance = balance
        self.blockscout = blockscout
        self.completion = completion
    }
    
    private func token(from response: BlockscoutGetTokenResponse?) -> HyperlootToken? {
        guard let tokenResponse = response?.token else {
            return nil
        }
        return HyperlootTokenTransformer.token(from: tokenResponse, balance: balance)
    }
    
    override func main() {
        guard let blockscout = blockscout else { return }
        
        run()
        blockscout.getToken(contractAddress: contractAddress, completion: { [weak self] (response, error) in
            guard let strongSelf = self, strongSelf.isCancelled == false else { return }
            
            DispatchQueue.main.async {
                strongSelf.completion(strongSelf.token(from: response))
                strongSelf.done()
            }
        })

    }
}
