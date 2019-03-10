//
//  DashboardTokenInfoSectionView.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

typealias DashboardTokenInfoSectionPresentation = DashboardTokenInfoSectionView.Presentation

protocol DashboardTokenInfoSectionDelegate: class {
    func didTapOnTokenInfoSection(view: DashboardTokenInfoSectionView)
}

class DashboardTokenInfoSectionView: UITableViewHeaderFooterView {
        
    struct Presentation {
        let tokenSymbol: String
        let tokenValue: String
        let hideSeparator: Bool
    }

    @IBOutlet weak var tokenSymbolLabel: UILabel!
    @IBOutlet weak var tokenValueLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    weak var delegate: DashboardTokenInfoSectionDelegate?
    
    lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnSection))
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addGestureRecognizer(tapGestureRecognizer)
    }
        
    public func update(presentation: DashboardTokenInfoSectionPresentation) {
        tokenSymbolLabel.text = presentation.tokenSymbol
        tokenValueLabel.text = presentation.tokenValue
        separatorView.isHidden = presentation.hideSeparator
    }
    
    @IBAction func didTapOnSection() {
        delegate?.didTapOnTokenInfoSection(view: self)
    }
}
