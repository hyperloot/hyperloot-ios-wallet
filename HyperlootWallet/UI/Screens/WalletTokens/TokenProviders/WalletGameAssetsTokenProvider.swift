//
//  WalletGameAssetsTokenProvider.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation

class WalletGameAssetsTokenProvider: WalletTokensProviding {
    
    struct Constants {
        static let currencyScreenTitle = "Collectibles"
        static let cellIdentifier = "wallet_token_currency_cell"
    }

    private var shouldShowActivityIndicator: Bool = false
    var assets: [WalletAsset] = []
    var gameAssetsDataSource: [WalletTokenCellConfiguration<Any>] = []
    var dataSourceAssets: [WalletAsset] = []
    
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
        return .gameAsset
    }
    
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
        let asset = dataSourceAssets[index]
        
        if asset.token.isERC721() && asset.token.hasTokenId() {
            return WalletTokenCellAction(screen: .showItemDetails, asset: asset)
        }
        
        return WalletTokenCellAction(screen: .showTransactions, asset: asset)
    }
    
    func sendItemAction(at index: Int) -> WalletTokenCellAction? {
        let asset = dataSourceAssets[index]
        guard asset.token.isERC721(), asset.token.hasTokenId() else {
            return nil
        }
        return WalletTokenCellAction(screen: .sendToken, asset: asset)
    }
}

extension WalletGameAssetsTokenProvider: WalletAssetsUpdating {
    
    private func gameAssetItemPresentation(asset: WalletAsset) -> WalletTokenGameAssetItemPresentation? {
        guard case .erc721(tokenId: let tokenId, totalCount: _, attributes: let attributes) = asset.value else {
            return nil
        }

        var name = attributes?.name ?? ""
        if name.isEmpty { name = asset.token.name }
        
        return WalletTokenGameAssetItemPresentation(itemImageURL: attributes?.imageURL,
                                                    itemName: name,
                                                    itemShortDescription: TokenFormatter.erc721Token(itemDescription: attributes?.description, tokenId: tokenId),
                                                    itemPrice: TokenFormatter.formattedPrice(doubleValue: asset.totalPrice))
    }
    
    func buildDataSource() {
        
        func isERC721(asset: WalletAsset) -> Bool {
            return asset.token.isERC721()
        }
        
        var dataSource: [WalletTokenCellConfiguration<Any>] = []
        dataSourceAssets.removeAll()
        
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
                
                // Need to transform first asset no Token with no ID to make it clickable
                func transformFirstAssetToNoID() -> WalletAsset {
                    guard let noIDMainItem = HyperlootTokenTransformer.tokenizedItem(from: firstAsset.token, tokenId: HyperlootToken.Constants.noTokenId, attributes: nil) else {
                        return firstAsset
                    }
                    return WalletAsset(token: noIDMainItem,
                                       price: firstAsset.price)
                }
                
                dataSourceAssets.append(transformFirstAssetToNoID())
                
                totalPrice = assetsForId.map { $0.totalPrice }.reduce(0.0, +)
                assetsForId.forEach { (asset) in
                    guard let presentation = gameAssetItemPresentation(asset: asset) else {
                        return
                    }
                    
                    totalPrice += asset.totalPrice
                    let configuration = WalletTokenCellConfiguration<Any>(cellIdentifier: WalletTokenGameAssetItemTableCell.viewId(),
                                                                          presentation: presentation)
                    items.append(configuration)
                    dataSourceAssets.append(asset)
                }
            } else {
                totalPrice = firstAsset.totalPrice
                dataSourceAssets.append(firstAsset)
            }

            let headerPresentation = WalletTokenGameAssetPresentation(tokenSymbol: TokenFormatter.tokenDisplay(name: firstAsset.token.name, symbol: firstAsset.token.symbol),
                                                                           tokenValue: TokenFormatter.formattedPrice(doubleValue: totalPrice))

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
