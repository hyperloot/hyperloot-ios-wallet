//
//  UserRegistration.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 9/23/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

enum UserRegistration {
    enum UserType {
        case new
        case existing
    }
    case email(String, userType: UserType)
    case emailAndPassword(email: String, password: String, userType: UserType)
    case createWallet(email: String, password: String, mnemonicPhrase: String)
    case importWalletWithPrivateKey(email: String, password: String, privateKey: String)
    case importWalletWithPhrase(email: String, password: String, phrase: String)
    case importWalletWithKeystore(email: String, password: String, keystoreJSON: String)
}
