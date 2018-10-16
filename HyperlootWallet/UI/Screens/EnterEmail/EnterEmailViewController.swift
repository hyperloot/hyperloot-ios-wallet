//
//  EnterEmailViewController.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 9/23/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

class EnterEmailViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var errorView: RegistrationErrorView!
    @IBOutlet weak var nextButton: UIButton!
    
    lazy var formController = FormController(scrollView: scrollView)
    
    lazy var viewModel = EnterEmailViewModel()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        formController.willShowForm()
        updateUIState()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        formController.willHideForm()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.isEqualTo(route: .showEnterPasswordScreen) {
            guard let viewController = segue.destination as? EnterPasswordViewController,
                let user = viewModel.user else {
                return
            }
            
            viewController.input = EnterPasswordViewController.Input(user: user)
        }
    }
    
    // MARK: - Updating UI state
    
    func updateUIState() {
        let presentation = viewModel.presentation
        nextButton.isEnabled = presentation.nextButtonEnabled
        errorView.setVisible(presentation.errorViewVisible, animated: true)
    }
    
    
    // MARK: - Actions
    
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        viewModel.textDidChange(textField.text)
        updateUIState()
    }
    
    @IBAction func nextButtonPressed() {
        viewModel.verify(email: emailTextField.text) { [weak self] (userType, error) in
            guard let strongSelf = self else {
                return
            }
            
            if userType != nil && error == nil {
                strongSelf.performSegue(route: .showEnterPasswordScreen)
            }
        }
        
    }
}

extension EnterEmailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        viewModel.textFieldDidReturn(textField.text)
        updateUIState()
        
        return true
    }
}
