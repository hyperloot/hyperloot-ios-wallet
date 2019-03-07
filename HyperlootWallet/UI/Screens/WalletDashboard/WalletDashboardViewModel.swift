//
//  WalletDashboardViewModel.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation

class WalletDashboardViewModel {
    
    struct Presentation {
        let headerTitle: String
        let numberOfCurrencies: String
        let numberOfGameAssets: String
        let currenciesBalance: String
        let gameAssetsBalance: String
    }
    
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
        return "0 currencies"
    }
    
    private var numberOfGameAssets: String {
        return "0 items"
    }
    
    private var currenciesBalance: String {
        return priceFormatter.string(from: 0) ?? "0.00"
    }
    
    private var gameAssetsBalance: String {
        return priceFormatter.string(from: 0) ?? "0.00"
    }
}
