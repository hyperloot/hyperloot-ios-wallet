//
//  EnterPasswordViewController.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 9/24/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

class EnterPasswordViewController: UIViewController {
    
    struct Input {
        let user: UserRegistration
    }
    
    var input: Input!
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var errorView: RegistrationErrorView!
    @IBOutlet weak var nextButton: HyperlootButton!
    
    lazy var viewModel = EnterPasswordViewModel(user: input.user)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUIState()
    }
    
    func updateUIState() {
        let presentation = viewModel.presentation
        
        confirmPasswordTextField.isHidden = presentation.isConfirmPasswordHidden
        errorView.isHidden = presentation.isErrorViewHidden
        nextButton.isEnabled = presentation.isNextButtonEnabled
    }
    
    // MARK: - Actions
    
    @IBAction func didChangePasswordField(_ textField: UITextField) {
        viewModel.didChangePassword(textField.text)
        updateUIState()
    }
    
    @IBAction func didChangeConfirmPasswordField(_ textField: UITextField) {
        viewModel.didChangeConfirmPassword(textField.text)
        updateUIState()
    }
    
    @IBAction func nextButtonPressed() {
        
    }
}

extension EnterPasswordViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        updateUIState()
        
        return true
    }
}
