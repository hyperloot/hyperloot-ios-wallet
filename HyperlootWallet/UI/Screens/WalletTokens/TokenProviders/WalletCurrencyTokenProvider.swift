//
//  WalletCurrencyTokenProvider.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation

class WalletCurrencyTokenProvider: WalletTokensProviding {
    
    struct Constants {
        static let currencyScreenTitle = "Currencies"
    }
    
    private var shouldShowActivityIndicator: Bool = false
    var assets: [WalletAsset] = []
    var completion: (() -> Void)? = nil
    
    var selectedAction: WalletTokenCellAction?
    
    let walletAssetManager: WalletAssetManager
    
    required init(walletAssetManager: WalletAssetManager) {
        self.walletAssetManager = walletAssetManager
    }
    
    var presentation: WalletTokensPresentation {
        return WalletTokensPresentation(totalAmount: totalAmount,
                                        title: Constants.currencyScreenTitle,
                                        shouldShowActivityIndicator: shouldShowActivityIndicator)
    }
    
    private lazy var priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = NSLocale.current
        return formatter
    } ()
    
    var totalAmount: String {
        let total = assets.map { $0.totalPrice }.reduce(0.0, +)
        return priceFormatter.string(from: NSNumber(value: total)) ?? "0.00"
    }
    
    // MARK: - Token Providing
    
    func load(completion: @escaping () -> Void) {
        self.completion = completion
        self.shouldShowActivityIndicator = true
        walletAssetManager.getAssets(listener: self)
    }
    
    func cellRegistrationInformation() -> [WalletTokensCellsRegistration] {
        return [WalletTokensCellsRegistration(cellIdentifier: WalletTokenCurrencyTableCell.viewId(),
                                              nibName: String(describing: WalletTokenCurrencyTableCell.self))]
    }
    
    func numberOfItems() -> Int {
        return assets.count
    }
    
    func cellConfiguration(at index: Int) -> WalletTokenCellConfiguration<Any> {
        let asset = assets[index]
        let presentation = WalletTokenCurrencyPresentation(icon: .none,
                                                           symbol: asset.token.symbol,
                                                           tokensAmount: "\(asset.tokensAmount)",
            amountInCurrency: priceFormatter.string(from: NSNumber(value: asset.totalPrice)) ?? "",
            index: index)
        return WalletTokenCellConfiguration(cellIdentifier: WalletTokenCurrencyTableCell.viewId(),
                                            presentation: presentation)
    }
    
    func actionForItem(at index: Int) -> WalletTokenCellAction? {
        let asset = assets[index]
        selectedAction = WalletTokenCellAction(screen: .showTransactions, asset: asset)
        return selectedAction
    }
}

extension WalletCurrencyTokenProvider: WalletAssetsUpdating {
    func didReceive(assets: [WalletAsset], cached: Bool) {
        self.assets = walletAssetManager.assets(by: .currency)
        shouldShowActivityIndicator = (cached != false)
        completion?()
    }
}
