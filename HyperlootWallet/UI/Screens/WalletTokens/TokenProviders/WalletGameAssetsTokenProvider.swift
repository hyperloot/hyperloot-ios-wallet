//
//  WalletGameAssetsTokenProvider.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation

class WalletGameAssetsTokenProvider: WalletTokensProviding {
    
    struct Constants {
        static let currencyScreenTitle = "Game assets"
        static let cellIdentifier = "wallet_token_currency_cell"
    }

    private var shouldShowActivityIndicator: Bool = false
    var assets: [WalletAsset] = []
    var gameAssetsDataSource: [WalletTokenCellConfiguration<Any>] = []
    
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
        return [WalletTokensCellsRegistration(cellIdentifier: WalletTokenGameAssetTableCell.viewId(),
                                              nibName: String(describing: WalletTokenGameAssetTableCell.self)),
                WalletTokensCellsRegistration(cellIdentifier: WalletTokenGameAssetItemTableCell.viewId(),
                                              nibName: String(describing: WalletTokenGameAssetItemTableCell.self))]
    }
    
    func numberOfItems() -> Int {
        return gameAssetsDataSource.count
    }
    
    func cellConfiguration(at index: Int) -> WalletTokenCellConfiguration<Any> {
        return gameAssetsDataSource[index]
    }
    
    func actionForItem(at index: Int) -> WalletTokenCellAction? {
        return nil
    }
}

extension WalletGameAssetsTokenProvider: WalletAssetsUpdating {
    
    private func gameAssetItemPresentation(asset: WalletAsset) -> WalletTokenGameAssetItemPresentation? {
        guard case .erc721(tokenId: _, totalCount: _, attributes: let attributes) = asset.value else {
            return nil
        }
        return WalletTokenGameAssetItemPresentation(itemImageURL: attributes?.imageURL,
                                                    itemName: attributes?.name ?? asset.token.name,
                                                    itemShortDescription: attributes?.description,
                                                    itemPrice: priceFormatter.string(from: NSNumber(value: asset.totalPrice)) ?? "0.00")
    }
    
    func buildDataSource() {
        
        func isERC721(asset: WalletAsset) -> Bool {
            return asset.token.isERC721()
        }
        
        var dataSource: [WalletTokenCellConfiguration<Any>] = []
        
        let assetIds = assets.map { $0.token.contractAddress }.reduce(into: Array<String>()) { (ids, assetId) in
            if ids.contains(assetId) == false {
                ids.append(assetId)
            }
        }
        assetIds.forEach { (assetId) in
            let assetsForId = assets.filter { $0.token.contractAddress == assetId }
            guard let firstAsset = assetsForId.first else {
                return
            }
            
            var totalPrice: Double
            var items: [WalletTokenCellConfiguration<Any>] = []
            if isERC721(asset: firstAsset) {
                totalPrice = assetsForId.map { $0.totalPrice }.reduce(0.0, +)
                assetsForId.forEach { (asset) in
                    guard let presentation = gameAssetItemPresentation(asset: asset) else {
                        return
                    }
                    
                    totalPrice += asset.totalPrice
                    let configuration = WalletTokenCellConfiguration<Any>(cellIdentifier: WalletTokenGameAssetItemTableCell.viewId(),
                                                                          presentation: presentation)
                    items.append(configuration)
                }
            } else {
                totalPrice = firstAsset.totalPrice
            }

            let headerPresentation = WalletTokenGameAssetPresentation(tokenSymbol: TokenFormatter.tokenDisplay(name: firstAsset.token.name, symbol: firstAsset.token.symbol),
                                                                           tokenValue: priceFormatter.string(from: NSNumber(value: totalPrice)) ?? "0.00")

            let headerCellConfiguration = WalletTokenCellConfiguration<Any>(cellIdentifier: WalletTokenGameAssetTableCell.viewId(),
                                                                            presentation: headerPresentation)
            
            dataSource.append(headerCellConfiguration)
            dataSource.append(contentsOf: items)
        }
        
        gameAssetsDataSource = dataSource
    }
    
    func didReceive(assets: [WalletAsset], cached: Bool) {
        self.assets = walletAssetManager.assets(by: .gameAsset)
        buildDataSource()
        shouldShowActivityIndicator = (cached != false)
        completion?()
    }
}
