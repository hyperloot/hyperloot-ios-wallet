//
//  BlockchainEnvironment.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation

enum Blockchain: Int, CaseIterable, Codable {
    case mainnet = 1
    case ropsten = 3
    case rinkeby = 4
    case kovan = 42
}

enum AppEnvironment: Int {
    case mainnet
    case testnet
}
