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
    }
    
    lazy var walletAssetManager: WalletAssetManager = WalletAssetManager()
    
    var currencies: [WalletAsset] = []
    var gameAssets: [WalletAsset] = []
    
    private lazy var priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = NSLocale.current
        return formatter
    } ()

    var presentation: Presentation {
        return Presentation(headerTitle: headerTitle,
                            numberOfCurrencies: numberOfCurrencies,
                            numberOfGameAssets: numberOfGameAssets,
                            currenciesBalance: currenciesBalance,
                            gameAssetsBalance: gameAssetsBalance)
    }
    
    var completion: Completion?
    
    public func getAssets(completion: @escaping Completion) {
        self.completion = completion
        walletAssetManager.getAssets(listener: self)
    }
    
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
        let total = currencies.map { $0.totalPrice }.reduce(0.0, +)
        return priceFormatter.string(from: NSNumber(value: total)) ?? "0.00"
    }
    
    private var gameAssetsBalance: String {
        let total = gameAssets.map { $0.totalPrice }.reduce(0.0, +)
        return priceFormatter.string(from: NSNumber(value: total)) ?? "0.00"
    }
}

extension WalletDashboardViewModel: WalletAssetsUpdating {
    func didReceive(assets: [WalletAsset], cached: Bool) {
        currencies = walletAssetManager.assets(by: .currency)
        gameAssets = walletAssetManager.assets(by: .gameAsset)
        completion?(cached)
    }
}
