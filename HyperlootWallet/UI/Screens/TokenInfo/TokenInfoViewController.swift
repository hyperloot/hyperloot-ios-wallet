//
//  TokenInfoViewController.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

/*
 TODO: Traits are not supported yet.
 */
class TokenInfoViewController: UIViewController {
    
    struct Input {
        let asset: WalletAsset
    }
    
    var input: Input!

    lazy var viewModel = TokenInfoViewModel(asset: self.input.asset)
    
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
        configureBackButtonWithNoText()
    }

    func updateUI() {
        let presentation = viewModel.presentation
        
        itemImageView.setImage(withURL: presentation.itemImageURL, placeholderImage: UIImage(named: "item_info_placeholder"), tag: view.tag)
        itemNameLabel.text = presentation.itemName
        itemShortDescriptionLabel.text = presentation.itemShortDescription
        itemPriceLabel.text = presentation.itemPrice
        itemDescriptionLabel.text = presentation.itemDescription
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.isEqualTo(route: .sendToken) {
            guard let viewController = segue.destination as? SendViewController else {
                return
            }
            viewController.input = SendViewController.Input(asset: viewModel.asset)
        }
    }
    @IBAction func sendButtonPressed() {
        performSegue(route: .sendToken)
    }
}
