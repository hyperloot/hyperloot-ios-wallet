//
//  UIView+Id.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

extension UIView {
    static public func viewId() -> String {
        return String(describing: self)
    }
}


extension UIView {
    static public func loadNib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle.main)
    }
}

extension UIView {
    static func animateIfNeeded(_ animated: Bool, duration: TimeInterval, block: @escaping () -> Void) {
        if animated {
            UIView.animate(withDuration: 0.25, animations: block)
        } else {
            block()
        }

    }
}
