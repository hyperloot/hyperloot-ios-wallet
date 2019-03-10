//
//  WalletTokensTableSectionHeaderView.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import UIKit

class WalletTokensTableSectionHeaderView: UIView {
    
    @IBOutlet weak var sectionNameLabel: UILabel!
    
    func update(sectionName: String) {
        sectionNameLabel.text = sectionName
    }
}
