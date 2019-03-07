//
//  HyperlootGradientLayer.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation
import UIKit

class HyperlootGradientLayer: CAGradientLayer {
    
    var isEnabled: Bool = true {
        didSet {
            let alpha: CGFloat = (isEnabled) ? 1.0 : 0.5
            self.colors = [
                UIColor(red: 0.87, green: 0.13, blue: 0.39, alpha: alpha).cgColor,
                UIColor(red: 0.81, green: 0.28, blue: 0.26, alpha: alpha).cgColor
            ]
        }
    }
    
    override init() {
        super.init()
        build()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        build()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        build()
    }
    
    private func build() {
        locations = [0, 1]
        startPoint = CGPoint(x: 0.25, y: 0.5)
        endPoint = CGPoint(x: 0.75, y: 0.5)
        isEnabled = true
    }

    
}
