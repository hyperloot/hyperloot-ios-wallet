//
//  UIPasteboard+Hyperloot.swift
//  HyperlootWallet
//

import Foundation
import UIKit
import MBProgressHUD

extension UIPasteboard {
    
    func copy(string: String, withHUDAddedTo view: UIView) {
        UIPasteboard.general.string = string
        
        let hudView = MBProgressHUD.showAdded(to: view, animated: true)
        hudView.mode = .text
        hudView.label.text = "Copied!"
        hudView.hide(animated: true, afterDelay: 1.2)
    }
}
