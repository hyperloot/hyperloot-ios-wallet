//
//  HyperlootDashboardCategoryView.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import UIKit

class HyperlootDashboardCategoryView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    lazy var gradient = HyperlootGradientLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.addSublayer(self.gradient)
        layer.cornerRadius = 10.0
        layer.masksToBounds = true
        bringSubview(toFront: contentView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.gradient.frame = bounds
    }
}
