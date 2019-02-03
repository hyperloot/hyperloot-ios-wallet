//
//  GasStation.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation
import BigInt
import TrustCore

class GasStation {
    
    struct Gas {
        let price: BigInt
        let limit: BigInt
    }
    
    struct GasPriceDefaults {
        static let min = EtherNumberFormatter.full.number(from: "1", units: .gwei)!
        static let regular = EtherNumberFormatter.full.number(from: "21", units: .gwei)!
    }
    
    let infura: Infura
    
    required init(infura: Infura) {
        self.infura = infura
    }
    
    func calculatedGasLimit(token: HyperlootToken) -> BigInt {
        switch token.type {
        case .ether:
            return BigInt(90_000)
        case .erc20:
            return BigInt(144_000)
        case .erc721:
            return BigInt(144_000)
        }
    }
    
    func calculatedGas(token: HyperlootToken) -> Gas {
        return Gas(price: GasPriceDefaults.regular,
                   limit: calculatedGasLimit(token: token))
    }
    
    func gas(from: Address, to: Address, value: BigInt, data: Data, token: HyperlootToken, completion: @escaping (Gas) -> Void) {
        gasPrice { [weak self] (gasPrice) in
            self?.estimateGas(from: from, to: to, value: value, gasPrice: gasPrice, data: data, token: token) { (gasLimit) in
                completion(Gas(price: gasPrice, limit: gasLimit))
            }
        }
    }
    
    private func estimateGas(from: Address, to: Address, value: BigInt, gasPrice: BigInt, data: Data, token: HyperlootToken, completion: @escaping (BigInt) -> Void) {
        let calculatedGas = calculatedGasLimit(token: token)
        infura.estimateGas(from: from.description, to: to.description, gasLimit: nil, gasPrice: gasPrice.hexString, value: value.hexString, data: data.hexString) { (response, error) in
            if let value = BigInt(hexString: response?.gasLimit) {
                completion(value)
            } else {
                completion(calculatedGas)
            }
        }
    }
    
    private func gasPrice(completion: @escaping (BigInt) -> Void) {
        infura.gasPrice { (response, error) in
            let gasPrice: BigInt
            if let value = BigInt(hexString: response?.gasPrice) {
                gasPrice = max(GasPriceDefaults.min, value)
            } else {
                gasPrice = GasPriceDefaults.regular
            }
            completion(gasPrice)
        }
    }
}
