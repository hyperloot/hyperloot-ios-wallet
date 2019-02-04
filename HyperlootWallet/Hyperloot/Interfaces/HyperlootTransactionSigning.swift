//
//  HyperlootTransactionSigning.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation
import TrustCore

protocol HyperlootTransactionSigning: class {
    func signTransaction(hash: Data, from address: Address) -> Data
}
