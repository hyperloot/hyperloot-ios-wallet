//
//  FindUserTableCell.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import UIKit

typealias FindUserPresentation = FindUserTableCell.Presentation

class FindUserTableCell: UITableViewCell {
    
    struct Presentation {
        let userNickname: String
        let walletAddress: String
    }
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var walletAddressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = AppStyle.Colors.defaultBackground
        self.selectedBackgroundView = selectedView
    }

    func update(presentation: Presentation) {
        userNameLabel.text = presentation.userNickname
        walletAddressLabel.text = presentation.walletAddress
    }
}
