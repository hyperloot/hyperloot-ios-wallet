//
//  SendViewController.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 10/4/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit
import QRCodeReaderViewController

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
        switch presentation.tokenPresentationType {
        case .regularToken(presentation: let presentation):
            tokenDetailsView.update(presentation: presentation)
        case .tokenItem(presentation: let presentation):
            tokenItemDetailsView.update(presentation: presentation)
        }
    }
    
    @IBAction func scanQRCodeButtonPressed() {
        let controller = QRCodeReaderViewController(cancelButtonTitle: "Cancel")
        controller.delegate = self
        self.navigationController?.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func sendButtonPressed() {
        // TODO: perform transaction
        self.navigationController?.popViewController(animated: true)
    }
}

extension SendViewController: QRCodeReaderDelegate {
    
    private func dismissQRCode(reader: QRCodeReaderViewController!) {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController!) {
        dismissQRCode(reader: reader)
    }
    
    func reader(_ reader: QRCodeReaderViewController!, didScanResult result: String!) {
        // TODO: pass value to view model and update text field
        dismissQRCode(reader: reader)
    }
}
