//
//  RegistrationErrorView.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

class RegistrationErrorView: UIView {
    
    @IBOutlet weak var textLabel: UILabel!
    
    private lazy var gradientLayer: CAGradientLayer = self.buildGradientLayer()
    
    public var text: String? {
        didSet {
            textLabel.text = text
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupAppearance()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
    }
    
    private func setupAppearance() {
        backgroundColor = UIColor.clear
        
        layer.addSublayer(self.gradientLayer)
        layer.masksToBounds = true
        layer.cornerRadius = 10
        
        textLabel.textColor = AppStyle.Colors.defaultText
        bringSubview(toFront: textLabel)
    }
    
    public func setVisible(_ value: Bool, animated: Bool) {
        let shouldBeHidden = !value
        guard shouldBeHidden != self.isHidden else {
            return
        }
        
        struct Alpha {
            let initial: CGFloat
            let final: CGFloat
        }
        
        let alpha = Alpha(initial: (value) ? 0.0 : 1.0, final: (value) ? 1.0 : 0.0)
        
        if animated == false {
            self.isHidden = !value
            self.alpha = alpha.final
        } else {
            self.alpha = alpha.initial
            self.isHidden = false
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                self?.alpha = alpha.final
            }) { [weak self] (_) in
                self?.isHidden = !value
            }
        }
    }
    
    private func buildGradientLayer() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.87, green: 0.13, blue: 0.39, alpha: 1.0).cgColor,
            UIColor(red: 0.81, green: 0.28, blue: 0.26, alpha: 1.0).cgColor
        ]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradient.endPoint = CGPoint(x: 0.75, y: 0.5)
        return gradient
    }
}
