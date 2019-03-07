//
//  WalletDashboardViewController.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

class GameAssetsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var balanceLabel: UILabel!
    
    lazy var viewModel = GameAssetsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureBackButtonWithNoText()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let shouldShowActivityIndicator = viewModel.shouldShowActivityIndicator
        
        if shouldShowActivityIndicator {
            showActivityIndicator()
        }
        viewModel.loadWallet { [weak self] in
            if shouldShowActivityIndicator {
                self?.hideActivityIndicator()
            }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.isEqualTo(route: .showTransactions) {
            guard let viewController = segue.destination as? TokenTransactionsViewController,
                let token = viewModel.selectedToken else {
                return
            }
            
            viewController.input = TokenTransactionsViewController.Input(token: token)
        } else if segue.isEqualTo(route: .showItemDetails) {
            guard let viewController = segue.destination as? TokenInfoViewController,
                let token = viewModel.selectedToken,
            case .erc721(tokenId: _, totalCount: _, attributes: let attributes) = token.type else {
                return
            }
            
            viewController.input = TokenInfoViewController.Input(token: token, attributes: attributes)
        }
    }
}

extension GameAssetsViewController: DashboardTokenInfoSectionDelegate {
    func didTapOnTokenInfoSection(view: DashboardTokenInfoSectionView) {
        let section = view.tag
        viewModel.didSelectTokenToShowTransactions(at: section)
        performSegue(route: .showTransactions)
    }
}

extension GameAssetsViewController: UITableViewDelegate {
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        viewModel.didSelectTokenToShowDetails(at: indexPath.row, section: indexPath.section)
        performSegue(route: .showItemDetails)
    }
}

extension GameAssetsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfTokensInSection(at: section)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: DashboardTokenInfoSectionView.viewId()) as? DashboardTokenInfoSectionView else {
            return nil
        }
        
        view.update(presentation: viewModel.presentationForToken(at: section))
        view.tag = section
        view.delegate = self
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DashboardTokenItemInfoTableCell.viewId(), for: indexPath) as? DashboardTokenItemInfoTableCell,
            let presentation = viewModel.presentationForItem(at: indexPath.row, section: indexPath.section) else {
            return UITableViewCell()
        }
        
        cell.update(presentation: presentation)
        cell.tag = indexPath.row
        return cell
    }
}
