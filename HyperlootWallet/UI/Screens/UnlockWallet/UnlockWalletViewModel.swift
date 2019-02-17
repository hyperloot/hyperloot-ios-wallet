//
//  UnlockWalletViewModel.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation

class UnlockWalletViewModel {
    
    struct Presentation {
        let walletAddress: String
    }
    
    private let user: UserRegistrationFlow
    
    var selectedImportMethod: UserRegistrationFlow.ImportType?
    
    init(user: UserRegistrationFlow) {
        self.user = user
    }
    
    var presentation: Presentation {
        return Presentation(walletAddress: walletAddress)
    }
    
    private var walletAddress: String {
        switch user {
        case .chooseImportOptions(user: let user, password: _):
            return user.walletAddress.description
        case .enterEmail, .signUpEnterNickname, .signUpConfirmPassword,
             .createWallet, .signInEnterPassword, .importWallet:
            return ""
        }
    }
    
    var registrationUser: UserRegistrationFlow? {
        
        guard let importType = selectedImportMethod else { return nil }
        
        switch user {
        case .chooseImportOptions(user: let user, password: let password):
            return UserRegistrationFlow.importWallet(user: user, password: password, importType: importType)
        case .enterEmail, .signUpEnterNickname, .signUpConfirmPassword,
             .createWallet, .signInEnterPassword, .importWallet:
            return nil
        }
    }
    
    public func didSelectImportMethod(value: Int) {
        selectedImportMethod = UserRegistrationFlow.ImportType(rawValue: value)
    }

}
