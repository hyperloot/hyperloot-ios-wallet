//
//  TransactionTableCell.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 10/3/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

typealias TransactionCellPresentation = TransactionTableCell.Presentation

class TransactionTableCell: UITableViewCell {
    
    struct Presentation {
        let date: String
        let tokenValue: BalanceFormatter.TransactionAmount
        let showTransactionValueSign: Bool
        let transactionHash: String
    }

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var transactionHashLabel: UILabel!
    
    public func update(presentation: TransactionCellPresentation) {
        dateLabel.text = presentation.date
        valueLabel.attributedText = presentation.tokenValue.toAttributedString(font: UIFont.boldSystemFont(ofSize: 20.0),
                                                                               showSign: presentation.showTransactionValueSign)
        transactionHashLabel.text = presentation.transactionHash
    }
}
