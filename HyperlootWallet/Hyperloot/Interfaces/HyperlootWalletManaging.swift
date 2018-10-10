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
    
    func createWallet(email: String, nickname: HyperlootNickname, password: String, completion: @escaping (_ address: String?, _ mnemonicPhraseWords: [String]?, _ error: Error?) -> Void)
    func importWallet()
}
