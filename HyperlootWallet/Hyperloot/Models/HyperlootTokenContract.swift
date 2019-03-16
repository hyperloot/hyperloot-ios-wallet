//
//  HyperlootTokenContract.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation

struct HyperlootTokenContract {
    struct Address {
        let addresses: [Blockchain: String]
    }
    
    enum TransferFunction {
        case transferFrom
        case transfer
    }
    
    enum TokenType {
        case ether
        case erc20
        case erc721
    }
    
    let name: String
    let symbol: String
    let decimals: Int
    let addresses: Address
    let type: TokenType
    let transferFunction: TransferFunction
    
    func mainnetAddress() -> String {
        return addressOrMainnetAddress(blockchain: .mainnet)
    }
    
    func addressOrMainnetAddress(blockchain: Blockchain) -> String {
        guard let address = addresses.addresses[blockchain] else {
            return addresses.addresses[.mainnet] ?? ""
        }
        return address
    }

}
