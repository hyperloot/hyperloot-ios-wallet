//
//  SplashViewController.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    
    lazy var viewModel = SplashViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if viewModel.hasWallets() {
            performSegue(route: .showWallet)
        } else {
            performSegue(route: .startLoginFlow)
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

