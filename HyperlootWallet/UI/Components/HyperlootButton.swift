//
//  HyperlootButton.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

class HyperlootButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupAppearance()
    }
    
    private func setupAppearance() {
        layer.cornerRadius = 10.0
        layer.masksToBounds = true
        
        setTitleColor(UIColor.black, for: .normal)
        setTitleColor(UIColor.lightGray, for: .disabled)
        titleLabel?.font = UIFont.systemFont(ofSize: 24.0)
    }
}
