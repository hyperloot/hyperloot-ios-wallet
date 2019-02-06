//
//  HyperlootTransactionSender.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation
import BigInt
import TrustCore
import Result

class HyperlootTransactionSender {
    
    typealias TransactionHash = String
    
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
    
    weak var transactionSigner: HyperlootTransactionSigning?
    weak var infura: Infura?
    
    required init(infura: Infura, transactionSigner: HyperlootTransactionSigning) {
        self.infura = infura
        self.transactionSigner = transactionSigner
    }
    
    public func approveAndSign(transaction: HyperlootTransactionSender.Transaction) -> Data? {
        var sendTransaction = TrustCore.Transaction(gasPrice: transaction.gasPrice,
                                                    gasLimit: UInt64(transaction.gasLimit.magnitude),
                                                    to: transaction.to)
        sendTransaction.sign(chainID: transaction.chainId) { (hash) -> Data in
            guard let transactionSigner = transactionSigner else { return Data() }
            return transactionSigner.signTransaction(hash: hash, from: transaction.from)
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
        return encodedData
    }

    public func send(transaction: HyperlootTransactionSender.Transaction, completion: @escaping (Result<TransactionHash, HyperlootTransactionSendError>) -> Void) {
        guard let data = approveAndSign(transaction: transaction) else {
            completion(.failure(.failedToSignTransaction))
            return
        }
        
        guard let infura = infura else {
            completion(.failure(.failedToSend))
            return
        }
        
        let transactionId = data.sha3(.keccak256).hexString
        let dataHexString = data.hexString
        
        infura.sendRawTransaction(signedTransactionDataInHex: dataHexString) { (response, error) in
            if error == nil && response != nil {
                completion(.success(transactionId))
            } else {
                completion(.failure(.failedToSend))
            }
        }
    }
}
