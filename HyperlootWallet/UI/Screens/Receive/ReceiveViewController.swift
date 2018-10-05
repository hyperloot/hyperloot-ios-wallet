//
//  ReceiveViewController.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 10/4/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit
import MBProgressHUD

class ReceiveViewController: UIViewController {
    
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var walletAddressLabel: UILabel!
    
    
    lazy var viewModel = ReceiveViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    func configureUI() {
        let presentation = viewModel.presentation
        
        qrCodeImageView.image = presentation.qrCodeImage
        walletAddressLabel.text = presentation.walletAddress
    }
    
    @IBAction func copyWalletAddressButtonPressed() {
        UIPasteboard.general.string = viewModel.walletAddress
        
        let hudView = MBProgressHUD.showAdded(to: view, animated: true)
        hudView.mode = .text
        hudView.label.text = "Copied!"
        hudView.hide(animated: true, afterDelay: 1.2)
    }
}
