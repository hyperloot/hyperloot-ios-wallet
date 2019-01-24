//
//  HyperlootTokensManaging.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 9/12/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

protocol HyperlootTokensManaging {
    func updateInventory(completion: @escaping ([HyperlootToken]) -> Void)
    func getTransactions(type: HyperlootTransactionType, page: Int, completion: @escaping ([HyperlootTransaction]) -> Void)
}
