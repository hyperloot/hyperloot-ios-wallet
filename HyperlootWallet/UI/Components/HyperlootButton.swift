//
//  HyperlootButton.swift
//  HyperlootWallet
//
//  Created by valery_vaskabovich on 9/19/18.
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
        titleLabel?.font = UIFont.systemFont(ofSize: 24.0)
    }
}
