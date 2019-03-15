//
//  HyperlootERC721DataHelper.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation
import TrustCore
import BigInt

class HyperlootERC721DataHelper {
    
    struct ERC721Contract {
        enum Function {
            case transferFrom
            case transfer
        }
        let name: String
        let addresses: [Blockchain: String]
        let function: Function
    }
    
    // Hardcoded contracts which have custom transfer function (not transferFrom)
    var contracts: [ERC721Contract] {
        return [
            ERC721Contract(name: "CryptoKitties",
                           addresses: [.mainnet : "0x06012c8cf97bead5deae237070f9587f8e7a266d", .rinkeby: "0x16baf0de678e52367adc69fd067e5edd1d33e3bf"],
                           function: .transfer)
        ]
    }
    
    func findContract(address: String, blockchain: Blockchain) -> ERC721Contract? {
        return contracts.first { (contract) -> Bool in
            return contract.addresses[blockchain] == address
        }
    }
    
    func data(token: HyperlootToken, from: Address, to: Address, tokenId: BigUInt) -> Data {
        var function: ERC721Contract.Function = .transferFrom
        if let contract = findContract(address: token.contractAddress, blockchain: token.blockchain) {
            function = contract.function
        }
        switch function {
        case .transferFrom:
            return ERC721Encoder.encodeTransferFrom(from: from, to: to, tokenId: tokenId)
        case .transfer:
            return ERC721Encoder.encodeTransfer(to: to, tokenId: tokenId)
        }
    }
    
}
