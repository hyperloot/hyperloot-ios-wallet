//
//  HyperlootWalletManaging.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 9/12/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

protocol HyperlootWalletManaging {
    
    func currentWallet() -> HyperlootWallet?
    
    func login(email: String, password: String, completion: @escaping (HyperlootUser?, Error?) -> Void)
    func createWallet(email: String, nickname: String, password: String, completion: @escaping (_ user: HyperlootUser?, _ mnemonicPhraseWords: [String]?, _ error: Error?) -> Void)
    func importWallet()
}
