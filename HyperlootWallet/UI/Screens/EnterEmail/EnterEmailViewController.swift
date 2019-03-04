//
//  EnterEmailViewController.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

class EnterEmailViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTextInput: HyperlootTextInputContainer!
    @IBOutlet weak var errorView: RegistrationErrorView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet var textInputBottomConstraint: NSLayoutConstraint!
    @IBOutlet var errorViewBottomConstraint: NSLayoutConstraint!
    
    lazy var formController = FormController(scrollView: scrollView)
    
    lazy var viewModel = EnterEmailViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureFormController()
        updateInputBottomConstraints()
    }
    
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
        guard let user = viewModel.user else {
            return
        }
        
        if segue.isEqualTo(route: .showEnterPasswordScreen) {
            guard let viewController = segue.destination as? EnterPasswordViewController else {
                return
            }
            
            viewController.input = EnterPasswordViewController.Input(user: user)
            
        } else if segue.isEqualTo(route: .showEnterNicknameScreen) {
            guard let viewController = segue.destination as? EnterNicknameViewController else {
                return
            }
            
            viewController.input = EnterNicknameViewController.Input(user: user)
        }
    }
    
    func configureFormController() {
        formController.textFieldDelegate = self
        formController.register(textFields: [emailTextInput.textField])
    }
    
    // MARK: - Updating UI state
    
    func updateUIState() {
        let presentation = viewModel.presentation
        nextButton.isEnabled = presentation.nextButtonEnabled
        errorView.setVisible(presentation.errorViewVisible, animated: true)
        
        updateInputBottomConstraints()
    }
    
    func updateInputBottomConstraints() {
        let presentation = viewModel.presentation
        errorViewBottomConstraint.isActive = presentation.errorViewVisible
        textInputBottomConstraint.isActive = !presentation.errorViewVisible
    }
    
    // MARK: - Actions
    
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        viewModel.textDidChange(textField.text)
        updateUIState()
    }
    
    @IBAction func nextButtonPressed() {
        showActivityIndicator()
        viewModel.verify(email: emailTextInput.textField.text) { [weak self] (user, error) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.hideActivityIndicator()
            
            if let nextScreen = self?.viewModel.nextScreen(), error == nil {
                strongSelf.performSegue(route: nextScreen)
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
