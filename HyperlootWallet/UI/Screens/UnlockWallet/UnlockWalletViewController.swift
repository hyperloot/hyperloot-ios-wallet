//
//  UnlockWalletViewController.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation
import UIKit

class UnlockWalletViewController: UIViewController {
    
    struct Input {
        let user: UserRegistrationFlow
    }
    
    var input: Input!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var walletAddressLabel: UILabel!
    
    lazy var viewModel = UnlockWalletViewModel(user: self.input.user)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
    }
    
    func updateUI() {
        let presentation = viewModel.presentation
        walletAddressLabel.text = presentation.walletAddress
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.isEqualTo(route: .showEnterWalletKeysScreen) {
            guard let viewController = segue.destination as? EnterWalletKeysViewController,
                let user = viewModel.registrationUser else {
                    return
            }
            
            viewController.input = EnterWalletKeysViewController.Input(user: user)
        }
    }
    
    @IBAction func importMethodButtonPressed(_ sender: Any) {
        guard let tag = (sender as? UIButton)?.tag else {
            return
        }
        viewModel.didSelectImportMethod(value: tag)
        performSegue(route: .showEnterWalletKeysScreen)
    }
}
