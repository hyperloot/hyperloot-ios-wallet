//
//  SplashViewController.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 9/10/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let viewController = UIStoryboard.init(name: Storyboards.loginFlow, bundle: nil).instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
}

