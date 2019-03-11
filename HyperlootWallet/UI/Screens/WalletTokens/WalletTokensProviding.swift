//
//  WalletTokensProviding.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation

struct WalletTokensPresentation {
    let totalAmount: String
    let title: String
    let shouldShowActivityIndicator: Bool
}

struct WalletTokensCellsRegistration {
    let cellIdentifier: String
    let nibName: String
}

class WalletTokenCellConfiguration<T> {
    let cellIdentifier: String
    let presentation: T
    
    required init(cellIdentifier: String, presentation: T) {
        self.cellIdentifier = cellIdentifier
        self.presentation = presentation
    }
}

class WalletTokenCellAction {
    let asset: WalletAsset
    let screen: ScreenRoute
    
    required init(screen: ScreenRoute, asset: WalletAsset) {
        self.screen = screen
        self.asset = asset
    }
}

protocol WalletTokenCellConfigurable {
    func update(configuration: WalletTokenCellConfiguration<Any>)
}

protocol WalletTokensProviding {
    var presentation: WalletTokensPresentation { get }
    
    func load(completion: @escaping () -> Void)
    
    func cellRegistrationInformation() -> [WalletTokensCellsRegistration]
    func numberOfItems() -> Int
    func cellConfiguration(at index: Int) -> WalletTokenCellConfiguration<Any>
    func actionForItem(at index: Int) -> WalletTokenCellAction?
}
