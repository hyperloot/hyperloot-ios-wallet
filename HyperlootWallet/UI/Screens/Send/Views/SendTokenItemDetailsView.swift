//
//  SendTokenItemDetailsView.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit
import AlamofireImage

typealias SendTokenItemDetailsPresentation = SendTokenItemDetailsView.Presentation

class SendTokenItemDetailsView: UIView {
    
    struct Presentation {
        let imageURL: String?
        let name: String
        let description: String?
        let price: String
    }

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemDescriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    func update(presentation: SendTokenItemDetailsPresentation) {
        itemImageView.setImage(withURL: presentation.imageURL, placeholderImage: UIImage(named: "item_placeholder"), tag: tag)
        itemNameLabel.text = presentation.name
        itemDescriptionLabel.text = presentation.description
        priceLabel.text = presentation.price
    }
}
