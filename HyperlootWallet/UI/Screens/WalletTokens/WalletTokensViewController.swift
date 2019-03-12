//
//  WalletTokensViewController.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import UIKit

class WalletTokensViewController: UIViewController {
    
    struct Input {
        let walletTokensProvider: WalletTokensProviding
    }
    
    var input: Input!
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var amountHeaderView: WalletTokensAmountHeaderView = Bundle.view(type: WalletTokensAmountHeaderView.self)
    
    var walletTokenProvider: WalletTokensProviding {
        return input.walletTokensProvider
    }
    
    var selectedAction: WalletTokenCellAction? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = walletTokenProvider.presentation.title
        configureBackButtonWithNoText()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        walletTokenProvider.load { [weak self] in
            self?.updateUI()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeaderLayout()
    }
    
    func configureTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.tableHeaderView = amountHeaderView
        walletTokenProvider.cellRegistrationInformation().forEach {
            let nib = UINib(nibName: $0.nibName, bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: $0.cellIdentifier)
        }
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func updateTableHeaderLayout() {
        let size = amountHeaderView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        let frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: size.height)
        amountHeaderView.frame = frame
    }
    
    func updateUI() {
        let presentation = walletTokenProvider.presentation
        amountHeaderView.update(amount: presentation.totalAmount)
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.isEqualTo(route: .showTransactions) {
            guard let action = selectedAction,
                let viewController = segue.destination as? TokenTransactionsViewController else {
                return
            }

            viewController.input = TokenTransactionsViewController.Input(asset: action.asset)
        } else if segue.isEqualTo(route: .showItemDetails) {
            guard let viewController = segue.destination as? TokenInfoViewController,
                let token = selectedAction?.asset.token,
                case .erc721(tokenId: _, totalCount: _, attributes: let attributes) = token.type else {
                    return
            }
            
            viewController.input = TokenInfoViewController.Input(token: token, attributes: attributes)
        }
    }
}

extension WalletTokensViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let action = walletTokenProvider.actionForItem(at: indexPath.row) else {
            return
        }
        selectedAction = action
        performSegue(route: action.screen)
    }
}

extension WalletTokensViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return walletTokenProvider.numberOfItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let configuration = walletTokenProvider.cellConfiguration(at: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: configuration.cellIdentifier, for: indexPath)
        guard let configurableCell = cell as? WalletTokenCellConfigurable else {
            return UITableViewCell()
        }
        
        configurableCell.update(configuration: configuration)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = Bundle.view(type: WalletTokensTableSectionHeaderView.self)
        let presentation = walletTokenProvider.presentation
        headerView.update(sectionName: presentation.title)

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
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}
