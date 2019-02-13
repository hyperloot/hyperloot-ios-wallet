//
//  DashboardTokenItemInfoTableCell.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit
import AlamofireImage

typealias DashboardTokenItemInfoPresentation = DashboardTokenItemInfoTableCell.Presentation

class DashboardTokenItemInfoTableCell: UITableViewCell {
    
    struct Presentation {
        let itemImageURL: String
        let itemName: String
        let itemShortDescription: String
        let itemPrice: NSAttributedString
    }
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemDescriptionLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func update(presentation: DashboardTokenItemInfoPresentation) {
        itemImageView.af_cancelImageRequest()
        if let imageURL = URL(string: presentation.itemImageURL) {
            itemImageView.af_setImage(withURL: imageURL)
        }
        itemNameLabel.text = presentation.itemName
        itemDescriptionLabel.text = presentation.itemShortDescription
        itemPriceLabel.attributedText = presentation.itemPrice
    }
}
