//
//  WalletTokenCurrencyTableCell.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import UIKit

typealias WalletTokenCurrencyPresentation = WalletTokenCurrencyTableCell.Presentation

class WalletTokenCurrencyTableCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var tokensAmountLabel: UILabel!
    @IBOutlet weak var amountInCurrencyLabel: UILabel!
    
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
        let symbol: String
        let tokensAmount: String
        let amountInCurrency: String
        let index: Int
    }
    
    var sendButtonCallback: WalletTokenSendButtonCallback?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = AppStyle.Colors.defaultBackground
        self.selectedBackgroundView = selectedView
    }
    
    func update(presentation: Presentation) {
        symbolLabel.text = presentation.symbol
        tokensAmountLabel.text = presentation.tokensAmount
        amountInCurrencyLabel.text = presentation.amountInCurrency
        
        switch presentation.icon {
        case .none:
            iconImageView.image = UIImage(named: Constants.placeholderIconImageName)
        case .imageName(let name):
            iconImageView.image = UIImage(named: name)
        case .imageURL(let imageURL):
            iconImageView.setImage(withURL: imageURL,
                                   placeholderImage: UIImage(named: Constants.placeholderIconImageName),
                                   tag: presentation.index)
        }
    }
    
    @IBAction func sendMoneyButtonTapped(_ sender: Any) {
        sendButtonCallback?()
    }
}

extension WalletTokenCurrencyTableCell: WalletTokenCellConfigurable {
    func update(configuration: WalletTokenCellConfiguration<Any>, sendButtonTapAction: WalletTokenSendButtonCallback?) {
        self.sendButtonCallback = sendButtonTapAction
        
        guard let presentation = configuration.presentation as? WalletTokenCurrencyPresentation else {
            return
        }
        
        update(presentation: presentation)
    }
}
