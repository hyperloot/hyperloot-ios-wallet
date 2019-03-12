//
//  TransactionTableCell.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

typealias TransactionCellPresentation = TransactionTableCell.Presentation

class TransactionTableCell: UITableViewCell {
    
    struct Constants {
        static let imageContainerWidth: CGFloat = 55.0
    }
    
    struct Presentation {
        enum Image {
            case none
            case imageURL(String?)
        }
        let date: String
        let tokenValue: BalanceFormatter.TransactionAmount
        let details: String
        let image: Image
    }

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet var imageContainerWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(hex: 0x222730)
        self.selectedBackgroundView = selectedView
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        itemImageView.prepareForReuse()
    }
    
    public func update(presentation: TransactionCellPresentation) {
        dateLabel.text = presentation.date
        valueLabel.attributedText = presentation.tokenValue.toAttributedString(font: UIFont.boldSystemFont(ofSize: 20.0), showSign: true)
        detailsLabel.text = presentation.details
        
        switch presentation.image {
        case .none:
            imageContainerView.isHidden = true
            imageContainerWidthConstraint.constant = 0.0
        case .imageURL(let imageURL):
            imageContainerView.isHidden = false
            imageContainerWidthConstraint.constant = Constants.imageContainerWidth
            itemImageView.setImage(withURL: imageURL, placeholderImage: UIImage(named: "item_placeholder"), tag: 0)
        }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
}
