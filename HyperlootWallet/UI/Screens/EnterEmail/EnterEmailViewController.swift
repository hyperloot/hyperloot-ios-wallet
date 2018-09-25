//
//  EnterEmailViewController.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 9/23/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

class EnterEmailViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var errorView: RegistrationErrorView!
    @IBOutlet weak var nextButton: UIButton!
    
    lazy var viewModel = EnterEmailViewModel()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        resetErrorView(animated: false)
        updateNextButtonState()
    }
    
    func updateNextButtonState() {
        let isValid = viewModel.isValid(email: emailTextField.text)
        nextButton.isEnabled = isValid
    }
    
    func resetErrorView(animated: Bool) {
        errorView.setVisible(false, animated: animated)
    }
    
    func updateErrorViewState(animated: Bool) {
        let isValid = viewModel.isValid(email: emailTextField.text)
        errorView.setVisible(!isValid, animated: animated)
    }
    
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        updateNextButtonState()
        resetErrorView(animated: true)
    }
    
    @IBAction func nextButtonPressed() {
    
    }
}

extension EnterEmailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        updateNextButtonState()
        updateErrorViewState(animated: true)
        textField.resignFirstResponder()
        
        return true
    }
}
