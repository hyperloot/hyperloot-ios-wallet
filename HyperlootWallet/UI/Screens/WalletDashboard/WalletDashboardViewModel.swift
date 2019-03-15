//
//  WalletDashboardViewModel.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation

class WalletDashboardViewModel {
    
    typealias Completion = (_ cached: Bool) -> Void
    
    struct Presentation {
        let headerTitle: String
        let numberOfCurrencies: String
        let numberOfGameAssets: String
        let currenciesBalance: String
        let gameAssetsBalance: String
        let showActivityIndicator: Bool
    }
    
    lazy var walletAssetManager: WalletAssetManager = WalletAssetManager()
    
    var currencies: [WalletAsset] = []
    var gameAssets: [WalletAsset] = []
    
    private var showActivityIndicator: Bool = false

    var presentation: Presentation {
        return Presentation(headerTitle: headerTitle,
                            numberOfCurrencies: numberOfCurrencies,
                            numberOfGameAssets: numberOfGameAssets,
                            currenciesBalance: currenciesBalance,
                            gameAssetsBalance: gameAssetsBalance,
                            showActivityIndicator: showActivityIndicator)
    }
    
    var completion: Completion?
    
    var tokensProviderForListScreen: WalletTokensProviding?
    
    public func getAssets(completion: @escaping Completion) {
        self.completion = completion
        showActivityIndicator = true
        walletAssetManager.getAssets(listener: self)
    }
    
    public func didSelectCurrenciesToShow() {
        tokensProviderForListScreen = WalletCurrencyTokenProvider(walletAssetManager: self.walletAssetManager)
    }
    
    public func didSelectGameAssetsToShow() {
        tokensProviderForListScreen = WalletGameAssetsTokenProvider(walletAssetManager: self.walletAssetManager)
    }
    
    // MARK: - Private
    private var headerTitle: String {
        var greeting: String
        if let user = Hyperloot.shared.user {
            greeting = "Hi, \(user.nickname.name)#\(user.nickname.identifier)!"
        } else {
            greeting = "Hi there!"
        }
        return "\(greeting)\nManage your assets"
    }
    
    private var numberOfCurrencies: String {
        return "\(currencies.count) currencies"
    }
    
    private var numberOfGameAssets: String {
        return "\(gameAssets.count) items"
    }
    
    private var currenciesBalance: String {
        return formattedBalanceOf(assetType: .currency)
    }
    
    private var gameAssetsBalance: String {
        return formattedBalanceOf(assetType: .gameAsset)
    }
    
    private func formattedBalanceOf(assetType: WalletAsset.AssetType) -> String {
        let assetsToCalculate: [WalletAsset]
        switch assetType {
            case .gameAsset: assetsToCalculate = gameAssets
            case .currency: assetsToCalculate = currencies
        }
        let total = assetsToCalculate.map { $0.totalPrice }.reduce(0.0, +)
        return TokenFormatter.formattedPrice(doubleValue: total)
    }
}

extension WalletDashboardViewModel: WalletAssetsUpdating {
    func didReceive(assets: [WalletAsset], cached: Bool) {
        currencies = walletAssetManager.assets(by: .currency)
        gameAssets = walletAssetManager.assets(by: .gameAsset)
        showActivityIndicator = cached != false
        completion?(cached)
    }
}
