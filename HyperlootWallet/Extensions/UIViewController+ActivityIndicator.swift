//
//  UIViewController+ActivityIndicator.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import MBProgressHUD

extension UIViewController {
    
    func showActivityIndicator(animated: Bool = true) {
        let hudView = MBProgressHUD.showAdded(to: self.view, animated: animated)
        hudView.bezelView.backgroundColor = AppStyle.Colors.darkContainer
        hudView.contentColor = AppStyle.Colors.defaultText
    }
    
    func hideActivityIndicator(animated: Bool = true) {
        MBProgressHUD.hide(for: self.view, animated: animated)
    }
}
