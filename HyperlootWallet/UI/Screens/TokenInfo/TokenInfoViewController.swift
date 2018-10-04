//
//  TokenInfoViewController.swift
//  HyperlootWallet
//
//  Created by valery_vaskabovich on 10/3/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

/*
 TODO: Traits are not supported yet.
 */
class TokenInfoViewController: UIViewController {
    
    struct Input {
        let token: HyperlootToken
        let attributes: HyperlootToken.Attributes
    }
    
    var input: Input!

    lazy var viewModel = TokenInfoViewModel(token: self.input.token, attributes: self.input.attributes)
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemShortDescriptionLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var itemDescriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationItem()
        updateUI()
    }
    
    func configureNavigationItem() {
        self.title = "Item Details"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send item", style: .plain, target: self, action: #selector(sendButtonPressed))
    }

    func updateUI() {
        let presentation = viewModel.presentation
        
        itemImageView.af_cancelImageRequest()
        if let imageURL = URL(string: presentation.itemImageURL) {
            itemImageView.af_setImage(withURL: imageURL)
        }
        itemNameLabel.text = presentation.itemName
        itemShortDescriptionLabel.text = presentation.itemShortDescription
        itemPriceLabel.attributedText = presentation.itemPrice
        itemDescriptionLabel.text = presentation.itemDescription
    }

    @IBAction func sendButtonPressed() {
        
    }
}
