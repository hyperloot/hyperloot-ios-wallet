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
    
    let walletAssetManager: WalletAssetManager
    
    required init(walletAssetManager: WalletAssetManager) {
        self.walletAssetManager = walletAssetManager
    }
    
    var presentation: WalletTokensPresentation {
        return WalletTokensPresentation(totalAmount: totalAmount,
                                        title: Constants.currencyScreenTitle,
                                        shouldShowActivityIndicator: shouldShowActivityIndicator)
    }
    
    var totalAmount: String {
        let total = assets.map { $0.totalPrice }.reduce(0.0, +)
        return TokenFormatter.formattedPrice(doubleValue: total)
    }
    
    // MARK: - Token Providing
    var assetsType: WalletAsset.AssetType {
        return .currency
    }
    
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
        let presentation = WalletTokenCurrencyPresentation(icon: .imageName(asset.token.symbol.lowercased()),
                                                           symbol: asset.token.symbol,
                                                           tokensAmount: "\(asset.tokensAmount)",
            amountInCurrency: TokenFormatter.formattedPrice(doubleValue: asset.totalPrice),
            index: index)
        return WalletTokenCellConfiguration(cellIdentifier: WalletTokenCurrencyTableCell.viewId(),
                                            presentation: presentation)
    }
    
    func actionForItem(at index: Int) -> WalletTokenCellAction? {
        let asset = assets[index]
        return WalletTokenCellAction(screen: .showTransactions, asset: asset)
    }
    
    func sendItemAction(at index: Int) -> WalletTokenCellAction? {
        let asset = assets[index]
        return WalletTokenCellAction(screen: .sendToken, asset: asset)
    }
}

extension WalletCurrencyTokenProvider: WalletAssetsUpdating {
    func didReceive(assets: [WalletAsset], cached: Bool) {
        var tokensSortPriority: [String: Int] = [:]
        var defaultTokens = HyperlootToken.defaultTokens(blockchain: .mainnet)
        defaultTokens.insert(HyperlootToken.ether(amount: "0", blockchain: .mainnet), at: 0)
        defaultTokens.enumerated().forEach { (index, token) in
            tokensSortPriority[token.contractAddress.lowercased()] = defaultTokens.count - index
        }
        
        self.assets = walletAssetManager.assets(by: .currency).sorted(by: { (a1, a2) -> Bool in
            let a1Index = tokensSortPriority[a1.assetId.lowercased()]
            let a2Index = tokensSortPriority[a2.assetId.lowercased()]
            if a1Index != nil || a2Index != nil {
                return (a1Index ?? -1) > (a2Index ?? -1)
            }
            return a1.totalPrice > a2.totalPrice
        })
        shouldShowActivityIndicator = (cached != false)
        completion?()
    }
}
