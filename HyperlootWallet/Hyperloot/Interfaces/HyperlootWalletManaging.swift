//
//  HyperlootWalletManaging.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 9/12/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

protocol HyperlootWalletManaging {
    func createWallet(email: String, password: String, completion: @escaping ([String]?, Error?) -> Void)
    func importWallet()
}
