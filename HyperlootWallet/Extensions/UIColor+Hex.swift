//
//  UIColor+Hex.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import UIKit

extension UIColor {

    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        self.init(red: CGFloat(((hex & 0xFF0000) >> 16)) / 255.0,
                  green: CGFloat(((hex & 0xFF00) >> 8)) / 255.0,
                  blue: CGFloat((hex & 0xFF)) / 255.0,
                  alpha: alpha)
    }
    
}
