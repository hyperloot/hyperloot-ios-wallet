//
//  HyperlootTextInputContainer.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import UIKit

class HyperlootTextInputContainer: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = AppStyle.Colors.darkContainer
        layer.cornerRadius = 10.0
        
        titleLabel.textColor = AppStyle.Colors.defaultText
        textField.textColor = AppStyle.Colors.defaultText
    }
    
}
