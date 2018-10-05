//
//  UIViewController+ScreenRoutes.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 9/25/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

extension UIViewController {
    func performSegue(route: ScreenRoute, sender: Any? = self) {
        performSegue(withIdentifier: route.rawValue, sender: sender)
    }
    
    func configureBackButtonWithNoText() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}

extension UIStoryboardSegue {
    func isEqualTo(route: ScreenRoute) -> Bool {
        return identifier == route.rawValue
    }
}
