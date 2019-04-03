//
//  EnterPasswordViewModel.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

class EnterPasswordViewModel {
    
    typealias NextStepCompletion = (ScreenRoute?) -> Void
    
    enum ValidationError: String, Error {
        case passwordsDoNotMatch = "Passwords do not match"
        case loginInvalidPassword = "Password is not correct. Please try again"
        case canNotCreateWallet = "Your wallet was not created. Please try again"
    }
    
    struct Presentation {
        let screenTitle: String
        let isConfirmPasswordHidden: Bool
        let error: (isHidden: Bool, text: String?)
        let isNextButtonEnabled: Bool
    }
    
    private var user: UserRegistrationFlow
    
    private var password: String?
    private var confirmPassword: String?
    private var errorToShow: ValidationError?
    
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
    
    private func buildPresentation(validationError: ValidationError? = nil) -> Presentation {
        
        guard let isNewUser = isNewUser else {
            // Error state, not supported
            return Presentation(screenTitle: "Error", isConfirmPasswordHidden: true, error: (isHidden: true, text: nil), isNextButtonEnabled: false)
        }
        
        return Presentation(screenTitle: (isNewUser) ? "Create your password" : "Enter password",
                            isConfirmPasswordHidden: isNewUser == false,
                            error: (isHidden: validationError == nil, text: validationError?.rawValue),
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
    
    private func validate() -> ValidationError? {
        let isNewUser = self.isNewUser ?? false
        if isNewUser && doPasswordsMatch() == false {
            let isConfirmPasswordEmpty = confirmPassword?.isEmpty ?? true
            return (isConfirmPasswordEmpty == false) ? .passwordsDoNotMatch : nil
        }
        return nil
    }
    
    public func updatePresentation() {
        if errorToShow == nil {
            errorToShow = validate()
        }
        presentation = self.buildPresentation(validationError: self.errorToShow)
        errorToShow = nil
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
    
    private func clearUserData() {
        password = nil
        confirmPassword = nil
    }
    
    private func reportFailure(error: ValidationError) {
        clearUserData()
        errorToShow = error
        updatePresentation()
    }
    
    private func proceedWithExistingUser(email: String, completion: @escaping NextStepCompletion) {
        guard let password = password else {
            return
        }
        
        Hyperloot.shared.login(email: email, password: password) { [weak self] (user, error) in
            guard let user = user else {
                self?.reportFailure(error: .loginInvalidPassword)
                completion(nil)
                return
            }
            self?.registeredUser = .chooseImportOptions(user: user, password: password)
            completion(.showImportOrCreateScreen)
        }
    }
    
    private func createNewAccount(email: String, nickname: String, completion: @escaping NextStepCompletion) {
        guard doPasswordsMatch(), let password = password else {
            return
        }
        
        Hyperloot.shared.createWallet(password: password) { [weak self] (address, words, error) in
            guard let address = address, let words = words else {
                self?.reportFailure(error: .canNotCreateWallet)
                completion(nil)
                return
            }
            
            self?.registeredUser = .createWallet(email: email, password: password, nickname: nickname, address: address, mnemonicPhrase: words)
            completion(.showEnterWalletKeysScreen)
        }
    }
}
