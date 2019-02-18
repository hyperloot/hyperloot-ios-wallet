//
//  UIViewController+ErrorHandling.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showError(title: String?, description: String?, actions: [UIAlertAction]? = nil, completion: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        if let actions = actions {
            actions.forEach { alert.addAction($0) }
        } else {
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        }
        present(alert, animated: true, completion: completion)
    }
    
}
