//
//  HyperlootTokensManaging.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import Result

enum HyperlootSendAmount {
    case amount(String)
    case uniqueToken
}

protocol HyperlootTokensManaging {
    func getPrices(for tokens: [HyperlootToken], cached: Bool, completion: @escaping ([HyperlootTokenPrice]) -> Void)
    func getCachedInventory(completion: @escaping ([HyperlootToken]) -> Void)
    func updateInventory(completion: @escaping ([HyperlootToken]) -> Void)
    func getTransactions(type: HyperlootTransactionType, page: Int, completion: @escaping ([HyperlootTransaction]) -> Void)
    func send(token: HyperlootToken, to: String, amount: HyperlootSendAmount, completion: @escaping (Result<HyperlootTransaction, HyperlootTransactionSendError>) -> Void)
}
