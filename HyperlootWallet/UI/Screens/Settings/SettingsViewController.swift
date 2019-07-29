//
//  SettingsViewController.swift
//  HyperlootWallet
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    
    lazy var viewModel = SettingsViewModel()
    
    fileprivate var selectedAction: SettingsViewModel.Action?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBackButtonWithNoText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let action = selectedAction else {
            return
        }
        
        if segue.isEqualTo(route: .exportKeys) {
            guard let viewController = segue.destination as? ExportViewController else {
                return
            }
            
            switch action {
            case .exportSeed(let seed):
                viewController.input = ExportViewController.Input(type: .seedPhrase, value: seed)
            case .exportPrivateKey(let privateKey):
                viewController.input = ExportViewController.Input(type: .privateKey, value: privateKey)
            case .selectNetwork:
                break
            }
        }
    }
    
}

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let presentation = viewModel.presentation(at: indexPath.row)
        return presentation.selectable ? indexPath : nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        showActivityIndicator()
        viewModel.performAction(for: indexPath.row) { [weak self] (action) in
            guard let action = action, let self = self else { return }
            
            self.hideActivityIndicator()
            
            self.selectedAction = action
            
            switch action {
            case .selectNetwork:
                break
            case .exportPrivateKey:
                self.performSegue(route: .exportKeys)
            case .exportSeed:
                self.performSegue(route: .exportKeys)
            }
        }
    }
    
}

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfSettingsEntries()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settings_cell", for: indexPath)
        if let updatableCell = cell as? SettingsCell {
            updatableCell.update(presentation: viewModel.presentation(at: indexPath.row))
        }
        
        return cell
    }
}
