//
//  TokenTransactionsViewController.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

class TokenTransactionsViewController: UIViewController {
    
    struct Input {
        let asset: WalletAsset
    }
    
    var input: Input!
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var viewModel = TokenTransactionsViewModel(asset: self.input.asset)

    override func viewDidLoad() {
        super.viewDidLoad()

        configureBackButtonWithNoText()
        configureUI()
        
        showActivityIndicator()
        viewModel.load { [weak self] in
            self?.hideActivityIndicator()
            self?.tableView.reloadData()
        }
    }
    
    private func configureUI() {
        let presentation = viewModel.presentation
        
        self.title = presentation.title
    }
}

extension TokenTransactionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TokenTransactionsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfTransactions()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TransactionTableCell.viewId(), for: indexPath) as? TransactionTableCell else {
            return UITableViewCell()
        }
        
        cell.update(presentation: viewModel.transaction(at: indexPath.row))
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = Bundle.view(type: WalletTokensTableSectionHeaderView.self)
        let presentation = viewModel.presentation
        headerView.update(sectionName: presentation.tableHeaderTitle)
        
        let size = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        let frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: size.height)
        headerView.frame = frame
        
        let view = UIView(frame: frame)
        view.addSubview(headerView)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }

}
