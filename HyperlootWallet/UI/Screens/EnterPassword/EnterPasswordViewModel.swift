//
//  EnterPasswordViewModel.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 9/24/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

class EnterPasswordViewModel {
    
    typealias NextStepCompletion = (ScreenRoute?) -> Void
    
    struct Presentation {
        let isConfirmPasswordHidden: Bool
        let isErrorViewHidden: Bool
        let isNextButtonEnabled: Bool
    }
    
    private var user: UserRegistrationFlow
    
    private var password: String?
    private var confirmPassword: String?
    
    public private(set) var registeredUser: UserRegistrationFlow?
    
    public private(set) lazy var presentation: Presentation = self.buildPresentation()
    
    init(user: UserRegistrationFlow) {
        self.user = user
    }
    
    private var isNewUser: Bool? {
        var newUser: Bool? = nil
        switch user {
        case .signInEnterPassword:
            newUser = false
        case .signUpConfirmPassword:
            newUser = true
        case .enterEmail, .signUpEnterNickname,
             .createWallet,
             .importWallet,
             .chooseImportOptions:
            newUser = nil
        }
        return newUser
    }
    
    private func buildPresentation(hideErrorView: Bool = true) -> Presentation {
        
        guard let isNewUser = isNewUser else {
            // Error state, not supported
            return Presentation(isConfirmPasswordHidden: true,
                                isErrorViewHidden: false,
                                isNextButtonEnabled: false)
        }
        
        return Presentation(isConfirmPasswordHidden: isNewUser == false,
                            isErrorViewHidden: hideErrorView,
                            isNextButtonEnabled: isNextButtonEnabled(isNewUser: isNewUser))
    }
    
    private func isNextButtonEnabled(isNewUser: Bool) -> Bool {
        if isNewUser {
            return doPasswordsMatch()
        } else {
            let isPasswordEmpty = password?.isEmpty ?? true
            return isPasswordEmpty == false
        }
    }
    
    private func doPasswordsMatch() -> Bool {
        guard let password = password, let confirmPassword = confirmPassword else {
            return false
        }
        
        return password == confirmPassword
    }
    
    // MARK: - Actions
    
    public func didChangePassword(_ value: String?) {
        password = value
        updatePresentation()
    }
    
    public func didChangeConfirmPassword(_ value: String?) {
        confirmPassword = value
        updatePresentation()
    }
    
    public func updatePresentation() {
        let isNewUser = self.isNewUser ?? false
        let shouldHideErrorView = (isNewUser) ? doPasswordsMatch() : true
        presentation = self.buildPresentation(hideErrorView: shouldHideErrorView)
    }
    
    public func proceedToTheNextStep(completion: @escaping NextStepCompletion) {
        
        switch user {
        case .signInEnterPassword(email: let email):
            proceedWithExistingUser(email: email, completion: completion)
        case .signUpConfirmPassword(email: let email, nickname: let nickname):
            createNewAccount(email: email, nickname: nickname, completion: completion)
        case .enterEmail, .signUpEnterNickname,
             .createWallet,
             .importWallet,
             .chooseImportOptions:
            
            // All other cases are not supported
            completion(nil)
        }
    }
    
    private func proceedWithExistingUser(email: String, completion: @escaping NextStepCompletion) {
        guard let password = password else {
            return
        }
        
        Hyperloot.shared.login(email: email, password: password) { [weak self] (user, error) in
            var nextScreen: ScreenRoute? = nil
            if let user = user {
                self?.registeredUser = .chooseImportOptions(user: user, password: password)
                nextScreen = .showImportOrCreateScreen
            }
            completion(nextScreen)
        }
    }
    
    private func createNewAccount(email: String, nickname: String, completion: @escaping NextStepCompletion) {
        guard doPasswordsMatch(), let password = password else {
            return
        }
        
        Hyperloot.shared.createWallet(email: email, nickname: nickname, password: password) { [weak self] (user, words, error) in
            guard let user = user, let words = words else {
                completion(nil)
                return
            }
            
            self?.registeredUser = .createWallet(user: user, password: password, mnemonicPhrase: words)
            completion(.showEnterWalletKeysScreen)
        }
    }
}
