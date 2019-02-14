//
//  TokenInventoryProviding.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation

protocol TokenInventoryProviding {
    func getInventoryItems(completion: @escaping ([HyperlootToken]) -> Void)
}
