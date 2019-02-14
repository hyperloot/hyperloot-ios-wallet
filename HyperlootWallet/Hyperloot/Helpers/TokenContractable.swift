//
//  TokenContractable.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

struct TokenContractableConstants {
    public static let tokenERC20Type = "ERC-20"
    public static let tokenERC721Type = "ERC-721"
}

protocol TokenContractable {
    var contractAddress: String? { get }
    var decimals: Int? { get }
    var name: String? { get }
    var symbol: String? { get }
    var totalSupply: String? { get }
    var type: String? { get }
    
    var imageURL: String? { get }
    var description: String? { get }
    var shortDescription: String? { get }
    var externalLink: String? { get }
}
