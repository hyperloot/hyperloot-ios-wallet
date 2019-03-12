//
//  WalletTokenGameAssetItemTableCell.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit
import AlamofireImage

typealias WalletTokenGameAssetItemPresentation = WalletTokenGameAssetItemTableCell.Presentation

class WalletTokenGameAssetItemTableCell: UITableViewCell {
    
    struct Presentation {
        let itemImageURL: String?
        let itemName: String
        let itemShortDescription: String?
        let itemPrice: String
    }
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemDescriptionLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    
    var sendButtonCallback: WalletTokenSendButtonCallback?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(hex: 0x222730)
        self.selectedBackgroundView = selectedView
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        itemImageView.prepareForReuse()
    }

    func update(presentation: WalletTokenGameAssetItemPresentation) {
        itemImageView.setImage(withURL: presentation.itemImageURL, placeholderImage: UIImage(named: "item_placeholder"), tag: self.tag)
        itemNameLabel.text = presentation.itemName
        itemDescriptionLabel.text = presentation.itemShortDescription
        itemPriceLabel.text = presentation.itemPrice
    }
    
    @IBAction func sendItemButtonTapped(_ sender: Any) {
        sendButtonCallback?()
    }
}

extension WalletTokenGameAssetItemTableCell: WalletTokenCellConfigurable {
    func update(configuration: WalletTokenCellConfiguration<Any>, sendButtonTapAction: WalletTokenSendButtonCallback?) {
        self.sendButtonCallback = sendButtonTapAction
        
        guard let presentation = configuration.presentation as? WalletTokenGameAssetItemPresentation else {
            return
        }
        update(presentation: presentation)
    }
}
