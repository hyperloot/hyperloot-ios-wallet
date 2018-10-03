//
//  HyperlootTransaction.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 10/3/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

struct HyperlootTransaction {

    enum Status: Int {
        case error = 0
        case success = 1
    }
    
    let transactionHash: String
    let contractAddress: String
    let timestamp: TimeInterval
    let from: String
    let to: String
    let status: Status
    let value: String
}
