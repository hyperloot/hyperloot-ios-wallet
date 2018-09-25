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
    
    public private(set) var user: UserRegistration? = nil
    
    public private(set) var presentation: Presentation = Presentation(nextButtonEnabled: false, errorViewVisible: false)
    
    public func verify(email: String?, completion: @escaping (UserRegistration.UserType?, Error?) -> Void) {
        guard let email = email else {
            completion(nil, NSError(domain: "com.hyperloot.wallet", code: -1, userInfo: nil))
            return
        }
        
        // TODO: make an API call to Hyperloot backend
        let userType: UserRegistration.UserType = .new
        user = .email(email, userType: userType)
        completion(userType, nil)
    }
    
    public func textDidChange(_ text: String?) {
        self.presentation = Presentation(nextButtonEnabled: EmailValidator.isValid(email: text), errorViewVisible: false)
    }
    
    public func textFieldDidReturn(_ text: String?) {
        let emailIsValid = EmailValidator.isValid(email: text)
        self.presentation = Presentation(nextButtonEnabled: emailIsValid, errorViewVisible: !emailIsValid)
    }
}
