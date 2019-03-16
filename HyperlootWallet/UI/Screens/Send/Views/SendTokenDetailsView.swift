//
//  SendTokenDetailsView.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

typealias SendTokenDetailsPresentation = SendTokenDetailsView.Presentation

class SendTokenDetailsView: UIView {
    
    struct Constants {
        static let placeholderIconImageName = "coin_list_placeholder"
    }
    
    struct Presentation {
        enum Image {
            case none
            case imageName(String)
            case imageURL(String)
        }
        let icon: Image
        let tokenSymbol: String
        let amountPlaceholderText: String
        let totalAvailableAmount: String
    }
    
    @IBOutlet weak var tokenIconImageView: UIImageView!
    @IBOutlet weak var tokenSymbolLabel: UILabel!
    @IBOutlet weak var totalAvailableLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    
    func update(presentation: SendTokenDetailsPresentation) {
        totalAvailableLabel.text = presentation.totalAvailableAmount
        tokenSymbolLabel.text = presentation.tokenSymbol
        amountTextField.attributedPlaceholder = NSAttributedString(string: presentation.amountPlaceholderText,
                                                                   attributes: [NSAttributedStringKey.foregroundColor: UIColor(hex: 0xf3f6fc, alpha: 0.1)])

        switch presentation.icon {
        case .none:
            tokenIconImageView.image = UIImage(named: Constants.placeholderIconImageName)
        case .imageName(let name):
            tokenIconImageView.image = UIImage(named: name) ?? UIImage(named: Constants.placeholderIconImageName)
        case .imageURL(let imageURL):
            tokenIconImageView.setImage(withURL: imageURL,
                                        placeholderImage: UIImage(named: Constants.placeholderIconImageName),
                                        tag: 0)
        }

    }
}
