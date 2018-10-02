//
//  WalletDashboardViewController.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 10/1/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

class WalletDashboardViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var balanceLabel: UILabel!
    
    lazy var viewModel = WalletDashboardViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.loadWallet { [weak self] in
            self?.updateBalance()
            self?.tableView.reloadData()
        }
    }

    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sectionHeaderHeight = CGFloat(44.0)
        tableView.separatorStyle = .none
        
        tableView.register(DashboardTokenInfoSectionView.loadNib(), forHeaderFooterViewReuseIdentifier: DashboardTokenInfoSectionView.viewId())
        tableView.register(DashboardTokenItemInfoTableCell.loadNib(), forCellReuseIdentifier: DashboardTokenItemInfoTableCell.viewId())
    }
    
    private func updateBalance() {
        balanceLabel.attributedText = viewModel.balance
    }
}

extension WalletDashboardViewController: UITableViewDelegate {
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension WalletDashboardViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfTokens()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItemsForToken(at: section)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: DashboardTokenInfoSectionView.viewId()) as? DashboardTokenInfoSectionView else {
            return nil
        }
        
        view.update(presentation: viewModel.presentationForToken(at: section))
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DashboardTokenItemInfoTableCell.viewId(), for: indexPath) as? DashboardTokenItemInfoTableCell,
            let presentation = viewModel.presentationForItem(at: indexPath.row, section: indexPath.section) else {
            return UITableViewCell()
        }
        
        cell.update(presentation: presentation)
        return cell
    }
}
