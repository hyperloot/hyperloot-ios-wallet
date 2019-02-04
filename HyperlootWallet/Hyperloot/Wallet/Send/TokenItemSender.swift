//
//  TokenItemSender.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation
import TrustCore
import BigInt
import Result

enum SendError: Error {
    case invalidNonceOrGasInfo
    case failedToSignTransaction
    case failedToSend
}

class TokenItemSender {
    
    struct Transaction {
        let from: Address
        let to: Address
        let value: BigInt
        let data: Data
        let gasLimit: BigInt
        let gasPrice: BigInt
        let nonce: BigInt
        let chainId: Int
    }
    
    let from: Address
    let to: Address
    let token: HyperlootToken
    let infura: Infura
    
    weak var transactionSigner: HyperlootTransactionSigning?
    
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
    
    required init(from: Address, to: Address, token: HyperlootToken, config: HyperlootConfig, infura: Infura? = nil, transactionSigner: HyperlootTransactionSigning) {
        self.from = from
        self.to = to
        self.token = token
        self.transactionSigner = transactionSigner
        
        if let infura = infura {
            self.infura = infura
        } else {
            self.infura = Infura(environment: token.blockchain, apiKey: config.infuraAPIKey)
        }
    }
    
    private func value(gas: GasStation.Gas) -> BigInt {
        switch token.type {
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
        switch token.type {
        case .ether:
            return Data()
        case .erc20(amount: let amount):
            let tokens = BigInt(stringLiteral: amount).magnitude
            return ERC20Encoder.encodeTransfer(to: self.to, tokens: tokens)
        case .erc721(tokenId: let tokenId, totalCount: _, attributes: _):
            let tokenIdValue = BigInt(stringLiteral: tokenId).magnitude
            return ERC721Encoder.encodeTransferFrom(from: self.from, to: self.to, tokenId: tokenIdValue)
        }
    }
    
    private func getGasInfo(completion: @escaping (GasStation.Gas) -> Void) {
        let calculatedGas = gasStation.calculatedGas(token: token)
        let approximateValue = value(gas: calculatedGas)
        gasStation.gas(from: self.from, to: self.to, value: approximateValue, data: self.data, token: self.token) { (gas) in
            completion(gas)
        }
    }
    
    func send(completion: @escaping (Result<HyperlootTransaction, SendError>) -> Void) {
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
            guard let strongSelf = self else { return }
            
            guard let nonce = currentNonce, let gas = gasInfo else {
                completion(.failure(.invalidNonceOrGasInfo))
                return
            }
            
            let value = strongSelf.value(gas: gas)
            let transaction = Transaction(from: strongSelf.from,
                                          to: strongSelf.to,
                                          value: value,
                                          data: strongSelf.data,
                                          gasLimit: gas.limit,
                                          gasPrice: gas.price,
                                          nonce: nonce,
                                          chainId: strongSelf.token.blockchain.rawValue)
            strongSelf.send(transaction: transaction, completion: completion)
        }
    }
    
    private func send(transaction: TokenItemSender.Transaction, completion: @escaping (Result<HyperlootTransaction, SendError>) -> Void) {
        var sendTransaction = TrustCore.Transaction(gasPrice: transaction.gasPrice,
                                                    gasLimit: UInt64(transaction.gasLimit.magnitude),
                                                    to: transaction.to)
        sendTransaction.sign(chainID: transaction.chainId) { [weak self] (hash) -> Data in
            guard let from = self?.from, let transactionSigner = transactionSigner else { return Data() }
            return transactionSigner.signTransaction(hash: hash, from: from)
        }
        
        let encodedData = RLP.encode([
            transaction.nonce,
            transaction.gasPrice,
            transaction.gasLimit,
            transaction.to.data,
            transaction.value,
            transaction.data,
            sendTransaction.v, sendTransaction.r, sendTransaction.s,
            ])
        guard let data = encodedData else {
            completion(.failure(.failedToSignTransaction))
            return
        }
        
        let transactionId = data.sha3(.keccak256).hexString
        let dataHexString = data.hexString
        
        infura.sendRawTransaction(signedTransactionDataInHex: dataHexString) { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            if error == nil && response != nil {
                completion(.success(strongSelf.pending(transactionHash: transactionId)))
            } else {
                completion(.failure(.failedToSend))
            }
        }
    }
    
    private func pending(transactionHash: String) -> HyperlootTransaction {
        let value: HyperlootTransactionValue
        switch token.type {
        case .ether(amount: let amount):
            value = .ether(value: amount)
        case .erc20(amount: let amount):
            value = .token(value: amount, decimals: token.decimals, symbol: token.symbol)
        case .erc721(tokenId: let tokenId, totalCount: _, attributes: _):
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
