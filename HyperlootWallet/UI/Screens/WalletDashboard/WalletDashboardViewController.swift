//
//  WalletDashboardViewController.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import UIKit

class WalletDashboardViewController: UIViewController {
    
    @IBOutlet weak var showQRCodeButton: HyperlootButton!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var numberOfCurrenciesLabel: UILabel!
    @IBOutlet weak var currenciesBalanceLabel: UILabel!
    @IBOutlet weak var numberOfGameAssetsLabel: UILabel!
    @IBOutlet weak var gameAssetsBalanceLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    lazy var viewModel = WalletDashboardViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.getAssets { [weak self] (cached: Bool) in
            self?.updateUI()
        }
    }
    
    func setup() {
        configureBackButtonWithNoText()
        showQRCodeButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        updateUI()
    }
    
    func updateUI() {
        let presentation = viewModel.presentation
        
        headerLabel.text = presentation.headerTitle
        numberOfCurrenciesLabel.text = presentation.numberOfCurrencies
        numberOfGameAssetsLabel.text = presentation.numberOfGameAssets
        currenciesBalanceLabel.text = presentation.currenciesBalance
        gameAssetsBalanceLabel.text = presentation.gameAssetsBalance
        if presentation.showActivityIndicator {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    // MARK: - Actions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.isEqualTo(route: .showWalletTokens) {
            guard let viewController = segue.destination as? WalletTokensViewController,
                let tokensProvider = viewModel.tokensProviderForListScreen else {
                return
            }
            viewController.input = WalletTokensViewController.Input(walletTokensProvider: tokensProvider)
        }
    }
    
    @IBAction func showCurrenciesButtonTapped(_ sender: Any) {
        viewModel.didSelectCurrenciesToShow()
        performSegue(route: .showWalletTokens)
    }
    
    @IBAction func showGameAssetsButtonTapped(_ sender: Any) {
        viewModel.didSelectGameAssetsToShow()
        performSegue(route: .showWalletTokens)
    }
}
