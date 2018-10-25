//
//  EnterWalletKeysViewModel.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 9/25/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

class EnterWalletKeysViewModel {
    
    struct Presentation {
        let title: String
        let hintText: String?
        let walletKeyTypeName: String
        let walletKey: (defaultValue: String, isEditable: Bool)
        let actionButton: (title: String, enabled: Bool)
    }
    
    let user: UserRegistrationFlow
    
    var walletKey: String?
    
    init(user: UserRegistrationFlow) {
        self.user = user
    }
    
    public var presentation: Presentation {
        return Presentation(title: screenTitle,
                            hintText: hintText,
                            walletKeyTypeName: walletKeyTypeName,
                            walletKey: (defaultValue: defaultWalletKey, isEditable: isWalletKeyEditable),
                            actionButton: (title: actionButtonTitle, enabled: isActionButtonEnabled))
    }
    
    // MARK: - Presentation
    
    private var screenTitle: String {
        switch user {
        case .createWallet(user: _, password: _, mnemonicPhrase: _):
            return "Create a new wallet"
        case .importWallet(user: _, password: _, importType: let importType):
            switch importType {
            case .privateKey:
                return "Please enter the private key for your wallet"
            case .mnemonicPhrase:
                return "Please enter the mnemonic phrase for your wallet"
            case .keystoreJSON:
                return "Please enter the Keystore JSON for your wallet"
            }
        case .enterEmail, .signUpEnterNickname(email: _),
             .signUpConfirmPassword(email: _, nickname: _), .signInEnterPassword(email: _),
             .chooseImportOptions(_, _):
            // Unsupported
            return ""
        }
    }
    
    private var hintText: String? {
        switch user {
        case .createWallet(user: _, password: _, mnemonicPhrase: _):
            return "Please save this activation phrase to access your wallet"
        case .importWallet(user: _, password: _, importType: _):
            return nil
        case .enterEmail, .signUpEnterNickname(email: _),
             .signUpConfirmPassword(email: _, nickname: _), .signInEnterPassword(email: _),
             .chooseImportOptions(_, _):
            // Unsupported
            return ""
        }
    }
    
    private var walletKeyTypeName: String {
        switch user {
        case .createWallet(user: _, password: _, mnemonicPhrase: _):
            return "Activation phrase"
        case .importWallet(user: _, password: _, importType: let importType):
            switch importType {
            case .privateKey:
                return "Private key"
            case .mnemonicPhrase:
                return "Activation phrase"
            case .keystoreJSON:
                return "Keystore JSON"
            }
        case .enterEmail, .signUpEnterNickname(email: _),
             .signUpConfirmPassword(email: _, nickname: _), .signInEnterPassword(email: _),
             .chooseImportOptions(_, _):
            // Unsupported
            return ""
        }
    }
    
    private var defaultWalletKey: String {
        switch user {
        case .createWallet(user: _, password: _, mnemonicPhrase: let words):
            return words.joined(separator: " ")
        case .importWallet(user: _, password: _, importType: _):
            return ""
        case .enterEmail, .signUpEnterNickname(email: _),
             .signUpConfirmPassword(email: _, nickname: _), .signInEnterPassword(email: _),
             .chooseImportOptions(_, _):
            // Unsupported
            return ""
        }
    }
    
    private var isWalletKeyEditable: Bool {
        switch user {
        case .createWallet(user: _, password: _, mnemonicPhrase: _):
            return false
        case .importWallet(user: _, password: _, importType: _):
            return true
        case .enterEmail, .signUpEnterNickname(email: _),
             .signUpConfirmPassword(email: _, nickname: _), .signInEnterPassword(email: _),
             .chooseImportOptions(_, _):
            // Unsupported
            return false
        }
    }
    
    private var actionButtonTitle: String {
        switch user {
        case .createWallet(user: _, password: _, mnemonicPhrase: _):
            return "Done"
        case .importWallet(user: _, password: _, importType: _):
            return "Import"
        case .enterEmail, .signUpEnterNickname(email: _),
             .signUpConfirmPassword(email: _, nickname: _), .signInEnterPassword(email: _),
             .chooseImportOptions(_, _):
            // Unsupported
            return ""
        }
    }
    
    private var isActionButtonEnabled: Bool {
        switch user {
        case .createWallet(user: _, password: _, mnemonicPhrase: _):
            return true
        case .importWallet(user: _, password: _, importType: _):
            return walletKey?.isEmpty == false
        case .enterEmail, .signUpEnterNickname(email: _),
             .signUpConfirmPassword(email: _, nickname: _), .signInEnterPassword(email: _),
             .chooseImportOptions(_, _):
            // Unsupported
            return false
        }
    }
}
