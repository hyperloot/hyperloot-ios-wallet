//
//  SendViewController.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit
import QRCodeReaderViewController

class SendViewController: UIViewController {
    
    struct Input {
        let asset: WalletAsset
    }
    
    var input: Input!
    
    lazy var viewModel = SendViewModel(asset: self.input.asset)
    
    lazy var formController = FormController(scrollView: self.scrollView)
    
    @IBOutlet weak var toAddressTextField: UITextField!
    
    // Sections
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tokenItemDetailsView: SendTokenItemDetailsView! // ERC-721
    @IBOutlet weak var tokenDetailsView: SendTokenDetailsView! // ERC-20

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        formController.willShowForm()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        formController.willHideForm()
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
        guard let to = toAddressTextField.text, to.isEmpty == false else { return }
        let amount = tokenDetailsView.amountTextField.text
        
        showActivityIndicator()
        viewModel.send(to: to, amount: amount) { [weak self] in
            self?.hideActivityIndicator()
            self?.navigationController?.popViewController(animated: true)
        }
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
