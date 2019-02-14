//
//  EnterWalletKeysViewController.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

class EnterWalletKeysViewController: UIViewController {
    
    struct Input {
        let user: UserRegistrationFlow
    }
    
    var input: Input!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hintTextLabel: UILabel!
    @IBOutlet weak var walletKeyTypeLabel: UILabel!
    @IBOutlet weak var walletKeyValueTextView: UITextView!
    @IBOutlet weak var actionButton: HyperlootButton!
    
    lazy var viewModel = EnterWalletKeysViewModel(user: self.input.user)
    
    lazy var formController = FormController(scrollView: self.scrollView)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
        formController.willShowForm()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        formController.willHideForm()
    }
    
    func updateUI() {
        let presentation = viewModel.presentation
        titleLabel.text = presentation.title
        hintTextLabel.text = presentation.hintText
        walletKeyTypeLabel.text = presentation.walletKeyTypeName
        walletKeyValueTextView.isEditable = presentation.walletKey.isEditable
        walletKeyValueTextView.text = presentation.walletKey.defaultValue
        actionButton.isEnabled = presentation.actionButton.enabled
        actionButton.setTitle(presentation.actionButton.title, for: .normal)
    }
    
    @IBAction func actionButtonPressed() {
        showActivityIndicator()
        viewModel.performAction { [weak self] (result) in
            self?.hideActivityIndicator()
            if result {
                self?.performSegue(route: .showWalletAfterLoginFlow)
            }
        }
    }
}
