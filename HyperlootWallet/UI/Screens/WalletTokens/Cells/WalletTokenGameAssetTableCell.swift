//
//  WalletTokenGameAssetTableCell.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

typealias WalletTokenGameAssetPresentation = WalletTokenGameAssetTableCell.Presentation

class WalletTokenGameAssetTableCell: UITableViewCell {
        
    struct Presentation {
        let tokenSymbol: String
        let tokenValue: String
    }

    @IBOutlet weak var tokenSymbolLabel: UILabel!
    @IBOutlet weak var tokenValueLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = AppStyle.Colors.defaultBackground
        self.selectedBackgroundView = selectedView
    }
    
    public func update(presentation: WalletTokenGameAssetPresentation) {
        tokenSymbolLabel.text = presentation.tokenSymbol
        tokenValueLabel.text = presentation.tokenValue
    }
}

extension WalletTokenGameAssetTableCell: WalletTokenCellConfigurable {
    func update(configuration: WalletTokenCellConfiguration<Any>, sendButtonTapAction: WalletTokenSendButtonCallback?) {
        guard let presentation = configuration.presentation as? WalletTokenGameAssetPresentation else {
            return
        }
        
        update(presentation: presentation)
    }
}
