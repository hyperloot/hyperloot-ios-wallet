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
        let user: UserRegistrationFlow
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.isEqualTo(route: .showEnterWalletKeysScreen) {
            guard let viewController = segue.destination as? EnterWalletKeysViewController,
                let user = viewModel.registeredUser else {
                    return
            }
            
            viewController.input = EnterWalletKeysViewController.Input(user: user)
        } else if segue.isEqualTo(route: .showImportOrCreateScreen) {
            
        }
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
        viewModel.proceedToTheNextStep { [weak self] (route) in
            guard let route = route else {
                return
            }
            
            self?.performSegue(route: route)
        }
    }
}

extension EnterPasswordViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        updateUIState()
        
        return true
    }
}
