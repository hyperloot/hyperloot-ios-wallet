//
//  OpenSeaInventoryProvider.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation

class OpenSeaInventoryProvider: TokenInventoryProviding {
    
    let openSea: OpenSea
    let walletAddress: String
    
    required init(openSea: OpenSea, walletAddress: String) {
        self.openSea = openSea
        self.walletAddress = walletAddress
    }
    
    func getInventoryItems(completion: @escaping ([HyperlootToken]) -> Void) {
        openSea.assets(ownerAddress: walletAddress) { [weak self] (response, error) in
            guard let assets = response?.assets else {
                completion([])
                return
            }
            self?.process(assets: assets, completion: completion)
        }
    }
    
    private func process(assets: [OpenSeaAsset], completion: @escaping ([HyperlootToken]) -> Void) {
        var tokens: [HyperlootToken] = []
        assets.forEach { (asset) in
            guard let tokenId = asset.tokenId, let assetContract = asset.assetContract,
                let token = HyperlootTokenTransformer.token(from: assetContract, balance: "0", blockchain: openSea.blockchain) else {
                    return
            }
            
            let traits: [HyperlootToken.Attributes.Trait] = asset.traits.map { (trait) in
                guard let type = trait.traitType, let value = trait.value else {
                    return nil
                }
                return HyperlootToken.Attributes.Trait(type: type, value: value)
                }.compactMap { $0 }
            
            let attributes = HyperlootToken.Attributes(description: asset.description ?? "",
                                                       shortDescription: nil,
                                                       name: asset.name ?? "",
                                                       imageURL: asset.imageURL,
                                                       traits: traits)
            
            guard let tokenizedItem = HyperlootTokenTransformer.tokenizedItem(from: token, tokenId: tokenId, attributes: attributes) else { return }
            tokens.append(tokenizedItem)
        }
        completion(tokens)
    }
}
