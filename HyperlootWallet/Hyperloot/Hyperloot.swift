//
//  Hyperloot.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 9/12/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

class Hyperloot {
    
    fileprivate let api = HyperlootAPI(environment: .testNet)
    fileprivate let blockscout = Blockscout(environment: .ropsten)
    fileprivate lazy var walletManager = WalletManager()
    fileprivate lazy var userManager = UserManager(api: self.api)
    
    public static let shared = Hyperloot()
}

extension Hyperloot: HyperlootTokensManaging {
    
    func getTokens() {
        guard let address = userManager.user?.walletAddress.description else { return }
        blockscout.getTokenList(address: "0xeadb31649e9f4d2ca155444d60144fcbf8b9190f") { (response, error) in
            print("\(response), \(error)")
        }
    }
    
    func getBalance() {
        
    }
}

extension Hyperloot: HyperlootWalletManaging {
    
    func currentWallet() -> HyperlootWallet? {
        guard let user = userManager.user else {
            return nil
        }
        
        return walletManager.wallet(byAddress: user.walletAddress)
    }
    
    func canRegister(email: String, completion: @escaping (Bool) -> Void) {
        userManager.canRegister(email: email, completion: completion)
    }
    
    func login(email: String, password: String, completion: @escaping (HyperlootUser?, Error?) -> Void) {
        userManager.login(email: email, password: password, completion: completion)
    }
    
    func signup(email: String, password: String, nickname: String, walletAddress: String, completion: @escaping (_ user: HyperlootUser?, _ error: Error?) -> Void) {
        userManager.createUser(withEmail: email, password: password, nickname: nickname, walletAddress: walletAddress, completion: completion)
    }
    
    func createWallet(email: String, password: String, completion: @escaping (_ address: String?, _ mnemonicPhraseWords: [String]?, _ error: Error?) -> Void) {
        walletManager.createWallet(email: email, password: password) { (info, error) in
            if let info = info {
                completion(info.address.description, info.mnemonicPhraseWords, nil)
            } else {
                completion(nil, nil, error)
            }
        }
    }
    
    func importWallet() {
        
    }
}
