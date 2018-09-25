//
//  UIViewController+ScreenRoutes.swift
//  HyperlootWallet
//
//  Created by valery_vaskabovich on 9/25/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

extension UIViewController {
    func performSegue(route: ScreenRoute, sender: Any? = self) {
        performSegue(withIdentifier: route.rawValue, sender: sender)
    }
}

extension UIStoryboardSegue {
    func isEqualTo(route: ScreenRoute) -> Bool {
        return identifier == route.rawValue
    }
}
