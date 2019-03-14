//
//  FindAUserViewController.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import UIKit

class FindAUserViewController: UIViewController {
    
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    lazy var viewModel = FindAUserViewModel()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        nicknameTextField.becomeFirstResponder()
    }
    
    // MARK: - Actions
    @IBAction func cancelButtonPressed() {
        nicknameTextField.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didChangeText() {
        viewModel.didChangeSearch(text: nicknameTextField.text) { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

extension FindAUserViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension FindAUserViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfUsers()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "user_search_cell", for: indexPath)
        if let updatableCell = cell as? FindUserTableCell {
            updatableCell.update(presentation: viewModel.presentation(at: indexPath.row))
        }
        
        return cell
    }
}
