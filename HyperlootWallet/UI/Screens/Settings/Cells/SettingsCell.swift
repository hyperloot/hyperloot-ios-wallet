//
//  SettingsCell.swift
//  HyperlootWallet
//

import UIKit

typealias SettingsPresentation = SettingsCell.Presentation

class SettingsCell: UITableViewCell {
    
    struct Presentation {
        let settingsKey: String
        let settingsValue: String?
        let selectable: Bool
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = AppStyle.Colors.defaultBackground
        self.selectedBackgroundView = selectedView
    }
    
    func update(presentation: Presentation) {
        titleLabel.text = presentation.settingsKey
        valueLabel.text = presentation.settingsValue
        selectionStyle = presentation.selectable ? .default : .none
    }
    
}
