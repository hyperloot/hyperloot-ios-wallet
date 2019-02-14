//
//  WalletGenerator.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import TrustKeystore
import CryptoSwift

class WalletGenerator {
    
    struct Constants {
        static let limitOfWallets = 1500
    }
    
    func generateAddresses(completion: @escaping () -> Void) {
        
        typealias GeneratedWallet = (address: String, privateKey: String, phrases: String)
        
        func generate(wallets: [String], completion: @escaping ([String]) -> Void) {
            
            func wallet(completion: @escaping (GeneratedWallet?) -> Void) {
                let mnemonic = Mnemonic.generate(strength: 128)
                let key = Wallet(mnemonic: mnemonic, passphrase: "", path: Wallet.defaultPath).getKey(at: 0)
                completion(GeneratedWallet(address: key.address.description, privateKey: key.privateKey.hexString, phrases: mnemonic))
            }
            
            var mutableWallets = wallets
            wallet { (wallet) in
                if let wallet = wallet {
                    let string = "\(wallet.address),\(wallet.privateKey),\(wallet.phrases.components(separatedBy: " ").joined(separator: ":"))"
                    mutableWallets.append(string)
                }
                
                if mutableWallets.count < Constants.limitOfWallets {
                    generate(wallets: mutableWallets, completion: completion)
                } else {
                    completion(mutableWallets)
                }
            }
        }
        
        generate(wallets: []) { (wallets) in
            print(wallets.joined(separator: "\n"))
            completion()
        }
    }
    
}
