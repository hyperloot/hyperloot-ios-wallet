//
//  ExportViewController.swift
//  HyperlootWallet
//

import UIKit

class ExportViewController: UIViewController {
        
    struct Input {
        let type: ExportType
        let value: String
    }
    
    var input: Input!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var exportTypeLabel: UILabel!
    @IBOutlet weak var valueTextField: UITextView!
    @IBOutlet weak var actionButton: HyperlootButton!
    
    lazy var viewModel = ExportViewModel(type: self.input.type, value: self.input.value)
    
    lazy var formController = FormController(scrollView: self.scrollView)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
        formController.willShowForm()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        formController.willHideForm()
    }
    
    func updateUI() {
        let presentation = viewModel.presentation
        exportTypeLabel.text = presentation.exportValueType
        valueTextField.text = presentation.value
    }
    
    @IBAction func actionButtonPressed() {
        UIPasteboard.general.copy(string: viewModel.value, withHUDAddedTo: view)
    }
}
