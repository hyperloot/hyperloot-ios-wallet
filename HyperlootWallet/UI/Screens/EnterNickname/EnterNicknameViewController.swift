//
//  EnterNicknameViewController.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

class EnterNicknameViewController: UIViewController {
    
    struct Input {
        let user: UserRegistrationFlow
    }
    
    var input: Input!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nicknameTextInput: HyperlootTextInputContainer!
    @IBOutlet weak var nextButton: UIButton!
    
    lazy var formController = FormController(scrollView: scrollView)
    
    lazy var viewModel = EnterNicknameViewModel(user: self.input.user)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formController.textFieldDelegate = self
        formController.register(textFields: [nicknameTextInput.textField])
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
        if segue.isEqualTo(route: .showEnterPasswordScreen) {
            guard let viewController = segue.destination as? EnterPasswordViewController,
                let user = viewModel.registrationUser else {
                    return
            }
            
            viewController.input = EnterPasswordViewController.Input(user: user)
        }
    }
    
    // MARK: - Updating UI state
    func updateUIState() {
        let presentation = viewModel.presentation
        nextButton.isEnabled = presentation.nextButtonEnabled
    }
    
    
    // MARK: - Actions
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        viewModel.textDidChange(textField.text)
        updateUIState()
    }
    
    @IBAction func nextButtonPressed() {
        nicknameTextInput.textField.resignFirstResponder()
        viewModel.textFieldDidReturn(nicknameTextInput.textField.text)
        if viewModel.registrationUser != nil {
            performSegue(route: .showEnterPasswordScreen)
        }
    }
}

extension EnterNicknameViewController: UITextFieldDelegate {
        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        viewModel.textFieldDidReturn(textField.text)
        updateUIState()
        
        return true
    }
}
