//
//  TokenContractable.swift
//  HyperlootWallet
//
//  Created by valery_vaskabovich on 12/13/18.
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
