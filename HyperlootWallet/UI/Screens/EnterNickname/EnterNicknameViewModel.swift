//
//  EnterNicknameViewModel.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

class EnterNicknameViewModel {
    
    struct Presentation {
        let nextButtonEnabled: Bool
    }
    
    private let user: UserRegistrationFlow
    public private(set) var registrationUser: UserRegistrationFlow?
    public private(set) var presentation: Presentation = Presentation(nextButtonEnabled: false)
    
    init(user: UserRegistrationFlow) {
        self.user = user
    }

    private func isNicknameValid(_ value: String?) -> Bool {
        let valueIsEmpty = value?.isEmpty ?? true
        return valueIsEmpty == false
    }
    
    public func textDidChange(_ text: String?) {
        self.presentation = Presentation(nextButtonEnabled: isNicknameValid(text))
    }
    
    public func textFieldDidReturn(_ text: String?) {
        let isValid = isNicknameValid(text)
        self.presentation = Presentation(nextButtonEnabled: isNicknameValid(text))

        if isValid == true, let nickname = text, case .signUpEnterNickname(let email) = user {
            registrationUser = .signUpConfirmPassword(email: email, nickname: nickname)
        }
    }
}
