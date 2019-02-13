//
//  HyperlootTransactionSendError.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation

enum HyperlootTransactionSendError: Error {
    case invalidNonceOrGasInfo
    case validationFailed
    case insufficientBalance
    case failedToSignTransaction
    case failedToSend
}
