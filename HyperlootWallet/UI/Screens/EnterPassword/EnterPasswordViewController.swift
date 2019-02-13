//
//  EnterPasswordViewController.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit
import MBProgressHUD

class EnterPasswordViewController: UIViewController {
    
    struct Input {
        let user: UserRegistrationFlow
    }
    
    var input: Input!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordContainerView: UIView!
    @IBOutlet weak var errorView: RegistrationErrorView!
    @IBOutlet weak var nextButton: HyperlootButton!
    
    lazy var viewModel = EnterPasswordViewModel(user: input.user)
    lazy var formController = FormController(scrollView: self.scrollView)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureFormController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUIState()
        formController.willShowForm()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        formController.willHideForm()
    }
    
    func configureFormController() {
        formController.textFieldDelegate = self
        formController.register(textFields: [passwordTextField, confirmPasswordTextField])
    }
    
    func updateUIState() {
        let presentation = viewModel.presentation
        
        confirmPasswordContainerView.isHidden = presentation.isConfirmPasswordHidden
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
        
        showActivityIndicator()
        
        viewModel.proceedToTheNextStep { [weak self] (route) in
            self?.hideActivityIndicator()
            
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
