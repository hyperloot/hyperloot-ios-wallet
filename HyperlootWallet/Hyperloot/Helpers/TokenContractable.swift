//
//  TokenContractable.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

protocol TokenContractable {
    var contractAddress: String? { get }
    var decimals: Int? { get }
    var name: String? { get }
    var symbol: String? { get }
    var totalSupply: String? { get }
    var type: String? { get }
}
