//
//  UserRegistration.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 9/23/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

enum UserRegistrationFlow {
    
    enum UserType {
        case new
        case existing
    }
    
    enum ImportType {
        case mnemonicPhrase
        case privateKey
        case keystoreJSON
    }
    
    case email(String, userType: UserType)
    case emailAndPassword(email: String, password: String)
    case createWallet(email: String, password: String, mnemonicPhrase: [String])
    case importWallet(email: String, password: String, importType: ImportType)
}
