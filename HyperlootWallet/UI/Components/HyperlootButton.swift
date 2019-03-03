//
//  HyperlootButton.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

class HyperlootButton: UIButton {
    
    private lazy var gradientLayer: CAGradientLayer = self.buildGradientLayer()
    
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
            gradientLayer.colors = gradientColors(enabled: isEnabled)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
    }
    
    private func gradientColors(enabled: Bool) -> [Any] {
        let alpha: CGFloat = (enabled) ? 1.0 : 0.5
        return [
            UIColor(red: 0.87, green: 0.13, blue: 0.39, alpha: alpha).cgColor,
            UIColor(red: 0.81, green: 0.28, blue: 0.26, alpha: alpha).cgColor
        ]
    }
    
    private func buildGradientLayer() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.colors = gradientColors(enabled: true)
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradient.endPoint = CGPoint(x: 0.75, y: 0.5)
        return gradient
    }
}
