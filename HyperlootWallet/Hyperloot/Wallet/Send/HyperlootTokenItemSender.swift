//
//  HyperlootTokenItemSender.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation
import TrustCore
import BigInt
import Result

class HyperlootTokenItemSender {
    
    enum SendingValue {
        case ether(amount: String)
        case erc20(amount: String)
        case erc721(tokenId: String)
    }
        
    let from: Address
    let to: Address
    let token: HyperlootToken
    let infura: Infura
    let sendingValue: SendingValue
    
    weak var transactionSigner: HyperlootTransactionSigning?
    let transactionSender: HyperlootTransactionSender
    
    lazy var nonceProvider = NonceProvider(infura: self.infura, address: self.from)
    lazy var gasStation = GasStation(infura: self.infura)
    
    var uniqueIdentifier: String {
        let tokenValue: String
        switch token.type {
        case .ether(amount: let amount):
            tokenValue = "ether=\(amount)"
        case .erc20(amount: let amount):
            tokenValue = "erc20=\(amount)"
        case .erc721(tokenId: let tokenId, totalCount: _, attributes: _):
            tokenValue = "erc721=\(tokenId)"
        }
        return "\(from.description)&\(to.description)&\(token.contractAddress)&\(tokenValue)&\(token.blockchain.rawValue)"
    }
    
    required init(from: Address, to: Address, token: HyperlootToken, sendingValue: SendingValue, config: HyperlootConfig, infura: Infura? = nil, transactionSigner: HyperlootTransactionSigning) {
        self.from = from
        self.to = to
        self.token = token
        self.transactionSigner = transactionSigner
        self.sendingValue = sendingValue
        
        if let infura = infura {
            self.infura = infura
        } else {
            self.infura = Infura(environment: token.blockchain, apiKey: config.infuraAPIKey)
        }
        
        self.transactionSender = HyperlootTransactionSender(infura: self.infura, transactionSigner: transactionSigner)
    }
    
    public func send(completion: @escaping (Result<HyperlootTransaction, HyperlootTransactionSendError>) -> Void) {
        var currentNonce: BigInt? = nil
        var gasInfo: GasStation.Gas? = nil
        
        let group = DispatchGroup()
        
        group.enter()
        nonceProvider.getNonce { (nonce, error) in
            currentNonce = nonce
            group.leave()
        }
        
        group.enter()
        getGasInfo { (gas) in
            gasInfo = gas
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.main) { [weak self] in
            guard let nonce = currentNonce, let gas = gasInfo else {
                completion(.failure(.invalidNonceOrGasInfo))
                return
            }
            
            self?.validate(gas: gas) { [weak self] (error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                self?.send(withGas: gas, nonce: nonce, completion: completion)
            }
        }
    }
    
    // MARK: - Private
    
    private func value(gas: GasStation.Gas) -> BigInt {
        switch sendingValue {
        case .ether(amount: let amount):
            let value = BigInt(stringLiteral: amount)
            guard value.isZero == false else {
                return 0
            }
            
            var transactionValue = value - gas.limit * gas.price
            if transactionValue.sign == .minus {
                transactionValue = BigInt(transactionValue.magnitude)
            }
            return transactionValue
        case .erc20, .erc721:
            return 0
        }
    }
    
    private var data: Data {
        switch sendingValue {
        case .ether:
            return Data()
        case .erc20(amount: let amount):
            let tokens = BigInt(stringLiteral: amount).magnitude
            return ERC20Encoder.encodeTransfer(to: self.to, tokens: tokens)
        case .erc721(tokenId: let tokenId):
            let tokenIdValue = BigInt(stringLiteral: tokenId).magnitude
            return ERC721Encoder.encodeTransferFrom(from: self.from, to: self.to, tokenId: tokenIdValue)
        }
    }
    
    private var transactionTo: Address {
        switch sendingValue {
        case .ether:
            return self.to
        case .erc20, .erc721:
            return Address(string: token.contractAddress) ?? self.to
        }
    }
    
    private func getGasInfo(completion: @escaping (GasStation.Gas) -> Void) {
        let calculatedGas = gasStation.calculatedGas(token: token)
        let approximateValue = value(gas: calculatedGas)
        gasStation.gas(from: self.from, to: transactionTo, value: approximateValue, data: self.data, token: self.token) { (gas) in
            completion(gas)
        }
    }
    
    private func validate(gas: GasStation.Gas, completion: @escaping (HyperlootTransactionSendError?) -> Void) {
        infura.getBalance(address: from.description, blockNumber: .latest) { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            guard let balance = BigInt(hexString: response?.balanceHex) else {
                completion(.validationFailed)
                return
            }
            
            let totalGasCost = gas.limit * gas.price
            let error: HyperlootTransactionSendError?
            switch strongSelf.sendingValue {
            case .erc20, .erc721:
                error = (totalGasCost > balance) ? .insufficientBalance : nil
            case .ether(amount: let amount):
                let etherValue = BigInt(stringLiteral: amount)
                error = (etherValue + totalGasCost > balance) ? .insufficientBalance : nil
            }
            completion(error)
        }
    }
    
    private func send(withGas gas: GasStation.Gas, nonce: BigInt, completion: @escaping (Result<HyperlootTransaction, HyperlootTransactionSendError>) -> Void) {
        let transaction = HyperlootTransactionSender.Transaction(from: from,
                                                                 to: transactionTo,
                                                                 value: value(gas: gas),
                                                                 data: data,
                                                                 gasLimit: gas.limit,
                                                                 gasPrice: gas.price,
                                                                 nonce: nonce,
                                                                 chainId: token.blockchain.rawValue)
        transactionSender.send(transaction: transaction) { [weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let transactionHash):
                completion(.success(strongSelf.pending(transactionHash: transactionHash)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func pending(transactionHash: String) -> HyperlootTransaction {
        let value: HyperlootTransactionValue
        switch sendingValue {
        case .ether(amount: let amount):
            value = .ether(value: amount)
        case .erc20(amount: let amount):
            value = .token(value: amount, decimals: token.decimals, symbol: token.symbol)
        case .erc721(tokenId: let tokenId):
            value = .uniqueToken(tokenId: tokenId)
        }
        
        return HyperlootTransaction(transactionHash: transactionHash,
                                    contractAddress: token.contractAddress,
                                    timestamp: Date().timeIntervalSince1970,
                                    from: self.from.description,
                                    to: self.to.description,
                                    status: .pending,
                                    value: value)
    }
}
