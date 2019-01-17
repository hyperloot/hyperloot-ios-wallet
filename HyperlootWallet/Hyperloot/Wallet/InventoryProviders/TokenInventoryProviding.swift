//
//  TokenInventoryProviding.swift
//  HyperlootWallet
//
//  Created by valery_vaskabovich on 1/13/19.
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation

protocol TokenInventoryProviding {
    func getInventoryItems(completion: @escaping ([HyperlootToken]) -> Void)
}
