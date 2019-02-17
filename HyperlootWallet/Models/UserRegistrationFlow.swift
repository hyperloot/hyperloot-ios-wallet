//
//  UserRegistration.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

enum UserRegistrationFlow {
    
    enum ImportType: Int {
        case mnemonicPhrase = 100
        case privateKey = 101
        case keystoreJSON = 102
    }
    
    // Entry point
    case enterEmail
    
    // New users: Email -> Nickname -> Password -> Create wallet
    case signUpEnterNickname(email: String)
    case signUpConfirmPassword(email: String, nickname: String)
    case createWallet(email: String, password: String, nickname: String, address: String, mnemonicPhrase: [String])
    
    // Existing users: Email -> Password -> Import wallet
    case signInEnterPassword(email: String)
    case chooseImportOptions(user: HyperlootUser, password: String)
    case importWallet(user: HyperlootUser, password: String, importType: ImportType)
}
