//
//  TokenTransactionsViewController.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 10/2/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

class TokenTransactionsViewController: UIViewController {
    
    struct Input {
        let token: HyperlootToken
    }
    
    var input: Input!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var balanceInCurrencyLabel: UILabel!
    @IBOutlet weak var balanceInCryptoLabel: UILabel!
    @IBOutlet weak var walletAddressLabel: UILabel!
    
    lazy var viewModel = TokenTransactionsViewModel(token: self.input.token)

    override func viewDidLoad() {
        super.viewDidLoad()

        configureBackButtonWithNoText()
        configureUI()
        
        viewModel.load { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    private func configureUI() {
        let presentation = viewModel.presentation
        
        self.title = presentation.title
        self.balanceInCurrencyLabel.attributedText = presentation.balanceInCurrency
        self.balanceInCryptoLabel.text = presentation.balanceInCrypto
        self.walletAddressLabel.text = presentation.walletAddress
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
}
