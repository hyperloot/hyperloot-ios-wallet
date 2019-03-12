//
//  WalletAssetManager.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation

protocol WalletAssetsUpdating: class {
    func didReceive(assets: [WalletAsset], cached: Bool)
}

class WalletAssetManager {
    
    enum State {
        case empty
        case loaded
        case updating
    }
    
    typealias Completion = () -> Void
    private var assets: [WalletAsset.AssetId: WalletAsset] = [:]
    private var state: State = .empty
    private var listeners = WeakRefArray<WalletAssetsUpdating>()
    
    public var allAssets: [WalletAsset] {
        return assets.values.map { $0 }
    }
    
    public func getAssets(listener: WalletAssetsUpdating) {
        guard hasListener(listener: listener) == false else {
            return
        }
        
        listeners.add(listener)
        
        loadCache { [weak self] in
            self?.notifyListeners(cached: true)
            self?.update {
                self?.notifyListeners(cached: false)
                self?.cleanupListeners()
            }
        }

    }
    
    public func assets(by type: WalletAsset.AssetType, removeZeroTokens: Bool = true) -> [WalletAsset] {
        func isERC721(asset: WalletAsset) -> Bool {
            return asset.token.isERC721()
        }
        
        func hasTokenId(asset: WalletAsset) -> Bool {
            return asset.token.hasTokenId()
        }
        
        var filteredAssets = allAssets.filter { $0.assetType == type }
        
        if removeZeroTokens {
            filteredAssets = filteredAssets.filter { !isERC721(asset: $0) || (isERC721(asset: $0) && hasTokenId(asset: $0)) }
        }
        
        return filteredAssets
    }
    
    // MARK: - Private
    private func loadCache(completion: @escaping Completion) {
        guard state == .empty else {
            completion()
            return
        }
        
        let hyperloot = Hyperloot.shared
        hyperloot.getCachedInventory { [weak self] (tokens) in
            hyperloot.getPrices(for: tokens, cached: true) { (prices) in
                self?.process(tokens: tokens, prices: prices) {
                    self?.state = .loaded
                    completion()
                }
            }
        }
    }
    
    private func update(completion: @escaping Completion) {
        guard state != .updating else {
            return
        }
        
        state = .updating
        let hyperloot = Hyperloot.shared
        hyperloot.updateInventory { [weak self] (tokens) in
            hyperloot.getPrices(for: tokens, cached: false) { (prices) in
                self?.process(tokens: tokens, prices: prices) {
                    self?.state = .loaded
                    completion()
                }
            }
        }
    }
    
    private func process(tokens: [HyperlootToken], prices: [HyperlootTokenPrice], completion: @escaping Completion) {
        typealias PriceDictionary = [String: HyperlootTokenPrice]
        let priceDict: PriceDictionary = prices.reduce(into: PriceDictionary(), { (dict, price) in
            dict[price.symbol] = price
        })
        
        tokens.forEach { (token) in
            let asset = WalletAsset(token: token, price: priceDict[token.symbol])
            assets[asset.assetId] = asset
        }
        completion()
    }
    
    // MARK: - Listeners
    private func cleanupListeners() {
        listeners.removeAll()
    }
    
    private func notifyListeners(cached: Bool) {
        listeners.allValues().forEach { (listener) in
            listener.didReceive(assets: allAssets, cached: cached)
        }
    }
    
    private func hasListener(listener: WalletAssetsUpdating) -> Bool {
        return listeners.allValues().contains { (l) -> Bool in
            return l === listener
        }
    }
}
