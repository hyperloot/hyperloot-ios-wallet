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
    
    lazy var formController = FormController(scrollView: self.scrollView, scrollViewTextFieldOffset: 150.0)
    
    @IBOutlet weak var toAddressTextField: UITextField!
    
    // Sections
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tokenItemDetailsView: SendTokenItemDetailsView! // ERC-721
    @IBOutlet weak var tokenDetailsView: SendTokenDetailsView! // ERC-20

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        formController.textFieldDelegate = self
        formController.register(textFields: [self.tokenDetailsView.amountTextField, toAddressTextField])
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
    
    func updateUI() {
        
    }
    
    @IBAction func scanQRCodeButtonPressed() {
        let controller = QRCodeReaderViewController(cancelButtonTitle: "Cancel")
        controller.delegate = self
        self.navigationController?.present(controller, animated: true, completion: nil)
    }
    
    private func showValidation(errors: [SendViewModel.ValidationError]) {
        let fieldsWithErrors = errors.map { "\($0.rawValue)\n" }
        let message = fieldsWithErrors.reduce(into: "The following fields are incorrect:\n") { (str, errorField) in
            str.append(errorField)
        }
        let controller = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(controller, animated: true, completion: nil)
    }
    
    private func showAlertForSend(error: HyperlootTransactionSendError) {
        let message = viewModel.errorMessage(sendError: error)
        let controller = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(controller, animated: true, completion: nil)
    }
    
    private func showAlertForSend(success transactionHash: String) {
        let message = "You've just sent your assets! Transaction confirmation: \(transactionHash)"
        let controller = UIAlertController(title: "Congratulations!", message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func sendButtonPressed() {
        formController.activeTextFieldResignFirstResponder()
        
        let validationErrors = viewModel.validate()
        guard validationErrors.isEmpty else {
            showValidation(errors: validationErrors)
            return
        }
        
        showActivityIndicator()
        viewModel.send { [weak self] (result) in
            self?.hideActivityIndicator()
            
            switch result {
            case .success(transactionHash: let hash):
                self?.showAlertForSend(success: hash)
                self?.navigationController?.popViewController(animated: true)
            case .error(let error):
                self?.showAlertForSend(error: error)
            }
        }
    }
    
    @IBAction func pasteButtonPressed() {
        guard let value = UIPasteboard.general.string else {
            return
        }
        
        enter(address: value, source: .paste)
    }
    
    func enter(address: String, source: SendViewModel.AddressSource) {
        let result = viewModel.update(address: address, source: source)
        switch result {
        case .dontUpdate: break // do nothing with text field
        case .update(value: let value):
            toAddressTextField.text = value
        }
        updateUI()
    }
    
    func enter(amount: String?) {
        let result = viewModel.didChangeAmount(value: amount)
        switch result {
        case .dontUpdate: break
        case .update(value: let value):
            tokenDetailsView.amountTextField.text = value
        }
    }
}

extension SendViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        switch textField {
        case tokenDetailsView.amountTextField:
            enter(amount: textField.text)
        case toAddressTextField:
            enter(address: toAddressTextField.text ?? "", source: .manual)
        default: break
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == tokenDetailsView.amountTextField {
            return viewModel.canChange(amount: textField.text, in: range, with: string)
        }
        
        return true
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
        enter(address: result, source: .scan)
        dismissQRCode(reader: reader)
    }
}
