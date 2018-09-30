//
//  SplashViewController.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 9/10/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    
    lazy var viewModel = SplashViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if viewModel.hasWallets() {
            performSegue(route: .showWallet)
        } else {
            performSegue(route: .startLoginFlow)
        }
        
    }
}

