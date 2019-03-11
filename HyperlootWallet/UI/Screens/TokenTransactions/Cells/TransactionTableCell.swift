//
//  TransactionTableCell.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

typealias TransactionCellPresentation = TransactionTableCell.Presentation

class TransactionTableCell: UITableViewCell {
    
    struct Presentation {
        let date: String
        let tokenValue: BalanceFormatter.TransactionAmount
        let showTransactionValueSign: Bool
        let details: String
    }

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    
    public func update(presentation: TransactionCellPresentation) {
        dateLabel.text = presentation.date
        valueLabel.attributedText = presentation.tokenValue.toAttributedString(font: UIFont.boldSystemFont(ofSize: 20.0),
                                                                               showSign: presentation.showTransactionValueSign)
        detailsLabel.text = presentation.details
    }
}
