//
//  NonceProvider.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation
import TrustCore
import BigInt

class NonceProvider {
    
    let infura: Infura
    let address: Address
    
    required init(infura: Infura, address: Address) {
        self.infura = infura
        self.address = address
    }
    
    func getNonce(completion: @escaping (BigInt?, Error?) -> Void) {
        infura.getTransactionCount(address: address.description, blockNumber: .latest) { (response, error) in
            if let value = BigInt(hexString: response?.numberOfTransactions) {
                completion(value, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
}
