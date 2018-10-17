//
//  EnterEmailViewModel.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 9/24/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

class EnterEmailViewModel {
    
    struct Presentation {
        let nextButtonEnabled: Bool
        let errorViewVisible: Bool
    }
    
    public private(set) var user: UserRegistrationFlow? = nil
    
    public private(set) var presentation: Presentation = Presentation(nextButtonEnabled: false, errorViewVisible: false)
    
    public func verify(email: String?, completion: @escaping (UserRegistrationFlow?, Error?) -> Void) {
        guard let email = email else {
            completion(nil, NSError(domain: "com.hyperloot.wallet", code: -1, userInfo: nil))
            return
        }
        
        // TODO: make an API call to Hyperloot backend
        let isNewUser = true
        if isNewUser {
            user = .signUpEnterNickname(email: email)
        } else {
            user = .signInEnterPassword(email: email)
        }
        completion(user, nil)
    }
    
    public func nextScreen() -> ScreenRoute? {
        guard let user = user else {
            return nil
        }
        
        switch user {
        case .signUpEnterNickname(email: _):
            return .showEnterNicknameScreen
        case .signInEnterPassword(email: _):
            return .showEnterPasswordScreen
        default:
            return nil
        }
    }
    
    public func textDidChange(_ text: String?) {
        self.presentation = Presentation(nextButtonEnabled: EmailValidator.isValid(email: text), errorViewVisible: false)
    }
    
    public func textFieldDidReturn(_ text: String?) {
        let emailIsValid = EmailValidator.isValid(email: text)
        self.presentation = Presentation(nextButtonEnabled: emailIsValid, errorViewVisible: !emailIsValid)
    }
}
