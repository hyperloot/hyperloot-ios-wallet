//
//  TokenContracts.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation

struct TokenContracts {
    typealias ContractAddress = HyperlootTokenContract.Address
    
    static let ethereum = HyperlootTokenContract(name: "Ethereum", symbol: "ETH", decimals: 18, addresses: ContractAddress(addresses: [.mainnet: "0x0"]), type: .ether, transferFunction: .transferFrom)
    static let hyperloot = HyperlootTokenContract(name: "HyperLoot", symbol: "HLT", decimals: 18, addresses: ContractAddress(addresses: [.mainnet: "0xA809d363A66c576A2a814CDBfEFC107C600A55f0"]), type: .erc20, transferFunction: .transferFrom)
    static let poa = HyperlootTokenContract(name: "POA Token", symbol: "POA", decimals: 18, addresses: ContractAddress(addresses: [.mainnet : "0x6758b7d441a9739b98552b373703d8d3d14f9e62"]), type: .erc20, transferFunction: .transferFrom)
    static let byteball = HyperlootTokenContract(name: "Byteball", symbol: "GBYTE", decimals: 18, addresses: ContractAddress(addresses: [.mainnet : "0x5E32E3250d4Ff17ea5044D510EDE9cAeC800470B"]), type: .erc20, transferFunction: .transferFrom)
    static let flip = HyperlootTokenContract(name: "Flip", symbol: "FLP", decimals: 18, addresses: ContractAddress(addresses: [.mainnet : "0x3a1Bda28AdB5B0a812a7CF10A1950c920F79BcD3"]), type: .erc20, transferFunction: .transferFrom)
    static let dmarket = HyperlootTokenContract(name: "DMarket", symbol: "DMT", decimals: 8, addresses: ContractAddress(addresses: [.mainnet : "0x2ccbFF3A042c68716Ed2a2Cb0c544A9f1d1935E1"]), type: .erc20, transferFunction: .transferFrom)
    static let wax = HyperlootTokenContract(name: "WAX Token", symbol: "WAX", decimals: 8, addresses: ContractAddress(addresses: [.mainnet : "0x39Bb259F66E1C59d5ABEF88375979b4D20D98022"]), type: .erc20, transferFunction: .transferFrom)
    static let enjinCoin = HyperlootTokenContract(name: "EnjinCoin", symbol: "ENJ", decimals: 18, addresses: ContractAddress(addresses: [.mainnet : "0xF629cBd94d3791C9250152BD8dfBDF380E2a3B9c"]), type: .erc20, transferFunction: .transferFrom)
    static let eGold = HyperlootTokenContract(name: "eGold", symbol: "EGL", decimals: 4, addresses: ContractAddress(addresses: [.mainnet : "0x8F00458479ea850f584ed82881421F9D9EaC6cB1"]), type: .erc20, transferFunction: .transferFrom)
}
