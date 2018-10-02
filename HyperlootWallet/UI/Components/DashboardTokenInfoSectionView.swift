//
//  DashboardTokenInfoSectionView.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 10/1/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

typealias DashboardTokenInfoSectionPresentation = DashboardTokenInfoSectionView.Presentation

class DashboardTokenInfoSectionView: UITableViewHeaderFooterView {
        
    struct Presentation {
        let tokenSymbol: String
        let tokenValue: String
        let hideSeparator: Bool
    }

    @IBOutlet weak var tokenSymbolLabel: UILabel!
    @IBOutlet weak var tokenValueLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
        
    public func update(presentation: DashboardTokenInfoSectionPresentation) {
        tokenSymbolLabel.text = presentation.tokenSymbol
        tokenValueLabel.text = presentation.tokenValue
        separatorView.isHidden = presentation.hideSeparator
    }
}
