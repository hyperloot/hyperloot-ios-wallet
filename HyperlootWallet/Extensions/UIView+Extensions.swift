//
//  UIView+Id.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 10/1/18.
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
