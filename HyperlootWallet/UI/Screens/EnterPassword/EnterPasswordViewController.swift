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
    @IBOutlet weak var screenTitleLabel: UILabel!
    @IBOutlet weak var passwordTextInput: HyperlootTextInputContainer!
    @IBOutlet weak var confirmPasswordTextInput: HyperlootTextInputContainer!
    @IBOutlet weak var errorView: RegistrationErrorView!
    @IBOutlet weak var nextButton: HyperlootButton!
    
    @IBOutlet var nextButtonNormalStateConstraint: NSLayoutConstraint!
    @IBOutlet var nextButtonErrorStateConstraint: NSLayoutConstraint!
    
    @IBOutlet var enterPasswordOnlyStateConstraint: NSLayoutConstraint!
    @IBOutlet var confirmPasswordStateConstraint: NSLayoutConstraint!
    
    lazy var viewModel = EnterPasswordViewModel(user: input.user)
    lazy var formController = FormController(scrollView: self.scrollView, scrollViewTextFieldOffset: 100)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUIState(animated: false)
        configureFormController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        resetState()
        updateUIState(animated: false)
        formController.willShowForm()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        formController.willHideForm()
    }
    
    func configureFormController() {
        formController.textFieldDelegate = self
        formController.register(textFields: [passwordTextInput.textField, confirmPasswordTextInput.textField])
    }
    
    func resetState() {
        passwordTextInput.textField.text = nil
        confirmPasswordTextInput.textField.text = nil
    }
    
    func updateUIState(animated: Bool = true) {
        let presentation = viewModel.presentation
        
        screenTitleLabel.text = presentation.screenTitle
        nextButton.isEnabled = presentation.isNextButtonEnabled
        configurePasswordFields(confirmPasswordHidden: presentation.isConfirmPasswordHidden)
        configureError(isHidden: presentation.error.isHidden, text: presentation.error.text)
        
        UIView.animateIfNeeded(animated, duration: 0.25) { [weak self] in
            self?.view.setNeedsLayout()
            self?.view.layoutIfNeeded()
        }
    }
    
    func configureError(isHidden: Bool, text: String?) {
        errorView.text = text
        errorView.setVisible(!isHidden, animated: true)
        
        nextButtonErrorStateConstraint.isActive = !isHidden
        nextButtonNormalStateConstraint.isActive = isHidden
    }
    
    func configurePasswordFields(confirmPasswordHidden: Bool) {
        confirmPasswordTextInput.isHidden = confirmPasswordHidden
        
        confirmPasswordStateConstraint.isActive = !confirmPasswordHidden
        enterPasswordOnlyStateConstraint.isActive = confirmPasswordHidden
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.isEqualTo(route: .showEnterWalletKeysScreen) {
            guard let viewController = segue.destination as? EnterWalletKeysViewController,
                let user = viewModel.registeredUser else {
                    return
            }
            
            viewController.input = EnterWalletKeysViewController.Input(user: user)
        } else if segue.isEqualTo(route: .showImportOrCreateScreen) {
            guard let viewController = segue.destination as? UnlockWalletViewController,
                let user = viewModel.registeredUser else {
                    return
            }
            
            viewController.input = UnlockWalletViewController.Input(user: user)
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
                self?.resetState()
                self?.updateUIState()
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
