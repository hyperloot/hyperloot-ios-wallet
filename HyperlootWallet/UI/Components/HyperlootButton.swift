//
//  HyperlootButton.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

class HyperlootButton: UIButton {
    
    private lazy var gradientLayer = HyperlootGradientLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupAppearance()
    }
    
    private func setupAppearance() {
        layer.addSublayer(self.gradientLayer)
        layer.cornerRadius = 10.0
        layer.masksToBounds = true
        
        backgroundColor = AppStyle.Colors.darkContainer
        setTitleColor(AppStyle.Colors.defaultText, for: .normal)
        setTitleColor(AppStyle.Colors.disabledText, for: .disabled)
        titleLabel?.font = UIFont.systemFont(ofSize: 20.0)
    }
    
    override var isEnabled: Bool {
        didSet {
            gradientLayer.isEnabled = isEnabled
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
    }
}
