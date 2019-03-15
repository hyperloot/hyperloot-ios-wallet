//
//  TokenListTotalAmountHeaderView.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import UIKit

class WalletTokensAmountHeaderView: UIView {
    
    @IBOutlet weak var amountLabel: UILabel!
    
    func update(amount: String) {
        amountLabel.text = amount
    }
}
