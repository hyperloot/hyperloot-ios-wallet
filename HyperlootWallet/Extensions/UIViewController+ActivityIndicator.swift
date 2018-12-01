//
//  UIViewController+ActivityIndicator.swift
//  HyperlootWallet
//
//  Created by valery_vaskabovich on 12/1/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import MBProgressHUD

extension UIViewController {
    
    func showActivityIndicator(animated: Bool = true) {
        MBProgressHUD.showAdded(to: self.view, animated: animated)
    }
    
    func hideActivityIndicator(animated: Bool = true) {
        MBProgressHUD.hide(for: self.view, animated: animated)
    }
}
