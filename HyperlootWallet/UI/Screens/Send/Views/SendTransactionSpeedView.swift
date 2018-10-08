//
//  SendTransactionSpeedView.swift
//  HyperlootWallet
//
//  Created by valery_vaskabovich on 10/7/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

class SendTransactionSpeedView: UIView {
    
    enum CheckType: Int {
        case regular
        case fast
    }
    
    struct Presentation {
        let selectedOption: CheckType
    }
    
    @IBOutlet var checkmarks: [UIImageView]!
    
    @IBAction func didSelectOption(_ sender: Any) {
        guard let gestureRecognizer = sender as? UITapGestureRecognizer,
            let view = gestureRecognizer.view,
            let type = CheckType(rawValue: view.tag) else {
            return
        }
        
        update(presentation: Presentation(selectedOption: type))
    }
    
    func update(presentation: Presentation) {
        checkmarks.forEach { $0.isHidden = ($0.tag != presentation.selectedOption.rawValue) }
    }
}
