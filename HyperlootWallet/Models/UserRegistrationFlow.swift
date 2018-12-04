//
//  UserRegistration.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 9/23/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

enum UserRegistrationFlow {
    
    enum ImportType {
        case mnemonicPhrase
        case privateKey
        case keystoreJSON
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
