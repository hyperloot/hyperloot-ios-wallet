//
//  SendTokenDetailsView.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

typealias SendTokenDetailsPresentation = SendTokenDetailsView.Presentation

class SendTokenDetailsView: UIView {
    
    struct Presentation {
        let tokenSymbol: String
        let amountPlaceholderText: String
    }
    
    @IBOutlet weak var tokenSymbolLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    
    func update(presentation: SendTokenDetailsPresentation) {
        tokenSymbolLabel.text = presentation.tokenSymbol
        amountTextField.placeholder = presentation.amountPlaceholderText
    }
}
