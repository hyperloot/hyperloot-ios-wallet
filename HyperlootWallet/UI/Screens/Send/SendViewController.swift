//
//  SendViewController.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 10/4/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

class SendViewController: UIViewController {
    
    struct Input {
        let token: HyperlootToken
    }
    
    var input: Input!
    
    lazy var viewModel = SendViewModel(token: self.input.token)
    
    // Sections
    @IBOutlet weak var tokenItemDetailsView: SendTokenItemDetailsView! // ERC-721
    @IBOutlet weak var tokenDetailsView: SendTokenDetailsView! // ERC-20

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    func configureUI() {
        let presentation = viewModel.presentation
        tokenDetailsView.isHidden = presentation.hideRegularTokenDetails
        tokenItemDetailsView.isHidden = presentation.hideTokenItemDetails
        switch presentation.tokenInfoType {
        case .regularToken(presentation: let presentation):
            tokenDetailsView.update(presentation: presentation)
        case .tokenItem(presentation: let presentation):
            tokenItemDetailsView.update(presentation: presentation)
        }
    }
}
