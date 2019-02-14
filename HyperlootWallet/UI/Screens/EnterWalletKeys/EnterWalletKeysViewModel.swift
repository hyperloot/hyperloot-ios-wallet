//
//  EnterWalletKeysViewModel.swift
//  HyperlootWallet
//
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
    
    enum PresentationSetting {
        case none
        case createWallet(mnemonicPhrase: [String])
        case importWallet(importType: UserRegistrationFlow.ImportType)
    }
    
    let user: UserRegistrationFlow
    
    var walletKey: String?
    
    var presentationSetting: PresentationSetting {
        switch user {
        case .createWallet(email: _, password: _, nickname: _, address: _, mnemonicPhrase: let words):
            return .createWallet(mnemonicPhrase: words)
        case .importWallet(user: _, password: _, importType: let importType):
            return .importWallet(importType: importType)
        case .enterEmail, .signUpEnterNickname,
             .signUpConfirmPassword, .signInEnterPassword,
             .chooseImportOptions:
            // Unsupported
            return .none
        }
    }
    
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
    
    public func performAction(completion: @escaping (Bool) -> Void) {
        switch user {
        case .createWallet(email: let email, password: let password, nickname: let nickname, address: let address, mnemonicPhrase: _):
            createWallet(email: email, password: password, nickname: nickname, walletAddress: address, completion: completion)
        case .importWallet(user: _, password: _, importType: _):
            break
        case .enterEmail, .signUpEnterNickname,
             .signUpConfirmPassword, .signInEnterPassword,
             .chooseImportOptions:
            // Unsupported
            break
        }
    }
    
    // MARK: - API calls
    public func createWallet(email: String, password: String, nickname: String, walletAddress: String, completion: @escaping (Bool) -> Void) {
        Hyperloot.shared.signup(email: email, password: password, nickname: nickname, walletAddress: walletAddress) { (user, error) in
            if user != nil, error == nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    // MARK: - Presentation
    private var screenTitle: String {
        switch presentationSetting {
        case .createWallet:
            return "Create a new wallet"
        case .importWallet(importType: let importType):
            switch importType {
            case .privateKey:
                return "Please enter the private key for your wallet"
            case .mnemonicPhrase:
                return "Please enter the mnemonic phrase for your wallet"
            case .keystoreJSON:
                return "Please enter the Keystore JSON for your wallet"
            }
        case .none:
            return ""
        }
    }
    
    private var hintText: String? {
        switch presentationSetting {
        case .createWallet:
            return "Please save this activation phrase to access your wallet"
        case .importWallet:
            return nil
        case .none:
            return ""
        }
    }
    
    private var walletKeyTypeName: String {
        switch presentationSetting {
        case .createWallet:
            return "Activation phrase"
        case .importWallet(importType: let importType):
            switch importType {
            case .privateKey:
                return "Private key"
            case .mnemonicPhrase:
                return "Activation phrase"
            case .keystoreJSON:
                return "Keystore JSON"
            }
        case .none:
            return ""
        }
    }
    
    private var defaultWalletKey: String {
        switch presentationSetting {
        case .createWallet(mnemonicPhrase: let words):
            return words.joined(separator: " ")
        case .importWallet:
            return ""
        case .none:
            return ""
        }
    }
    
    private var isWalletKeyEditable: Bool {
        switch presentationSetting {
        case .createWallet:
            return false
        case .importWallet:
            return true
        case .none:
            return false
        }
    }
    
    private var actionButtonTitle: String {
        switch presentationSetting {
        case .createWallet:
            return "Done"
        case .importWallet:
            return "Import"
        case .none:
            return ""
        }
    }
    
    private var isActionButtonEnabled: Bool {
        switch presentationSetting {
        case .createWallet:
            return true
        case .importWallet:
            return walletKey?.isEmpty == false
        case .none:
            return false
        }
    }
}
