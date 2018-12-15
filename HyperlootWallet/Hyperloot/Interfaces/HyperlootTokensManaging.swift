//
//  HyperlootTokensManaging.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 9/12/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

protocol HyperlootTokensManaging {
    func getTokens(completion: @escaping ([HyperlootToken]) -> Void)
    func getBalance(completion: @escaping (HyperlootToken) -> Void)
}
