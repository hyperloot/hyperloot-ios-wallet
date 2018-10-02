//
//  DashboardTokenItemInfoTableCell.swift
//  HyperlootWallet
//
//  Created by valery_vaskabovich on 9/30/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit
import Alamofire

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
        
    }
}
