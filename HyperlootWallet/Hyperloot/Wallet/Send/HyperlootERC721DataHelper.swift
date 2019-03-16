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
    
    // Hardcoded contracts which have custom transfer function (not transferFrom)
    var contracts: [HyperlootTokenContract] {
        return [
            HyperlootTokenContract(name: "CryptoKitties",
                                   symbol: "CK",
                                   decimals: 0,
                                   addresses: HyperlootTokenContract.Address(addresses: [.mainnet: "0x06012c8cf97bead5deae237070f9587f8e7a266d",
                                                                                         .rinkeby: "0x16baf0de678e52367adc69fd067e5edd1d33e3bf"]),
                                   type: .erc721,
                                   transferFunction: .transfer)
        ]
    }
    
    func findContract(address: String, blockchain: Blockchain) -> HyperlootTokenContract? {
        return contracts.first { (contract) -> Bool in
            return contract.addressOrMainnetAddress(blockchain: blockchain) == address
        }
    }
    
    func data(token: HyperlootToken, from: Address, to: Address, tokenId: BigUInt) -> Data {
        var function: HyperlootTokenContract.TransferFunction = .transferFrom
        if let contract = findContract(address: token.contractAddress, blockchain: token.blockchain) {
            function = contract.transferFunction
        }
        switch function {
        case .transferFrom:
            return ERC721Encoder.encodeTransferFrom(from: from, to: to, tokenId: tokenId)
        case .transfer:
            return ERC721Encoder.encodeTransfer(to: to, tokenId: tokenId)
        }
    }
    
}
