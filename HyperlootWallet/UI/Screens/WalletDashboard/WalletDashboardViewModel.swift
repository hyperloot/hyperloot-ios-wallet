//
//  WalletDashboardViewModel.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 10/1/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

class WalletDashboardViewModel {
    
    struct DataSourceSection {
        let sectionId: String
        let presentation: DashboardTokenInfoSectionPresentation
        let items: [DashboardTokenItemInfoPresentation]
    }
    
    private var dataSource: [DataSourceSection] = []
    private var tokens: [HyperlootToken] = []
    
    func loadWallet(completion: () -> Void) {
        
        func hlq3Token(tokenId: String, attributes: HyperlootToken.Attributes) -> HyperlootToken {
            return HyperlootToken(cataloged: true, contractAddress: "0x4321", name: "Hyperloot Q3", symbol: "HLQ3", decimals: 0, totalSupply: 3, type: .erc721(tokenId: tokenId, attributes: attributes))
        }
        
        // TODO: use API to get tokens
        tokens = [ HyperlootToken(cataloged: false, contractAddress: "0x12345", name: "Hyperloot Token", symbol: "HLT", decimals: 0, totalSupply: 100000, type: .erc20),
                   HyperlootToken(cataloged: false, contractAddress: "0x12", name: "Ethereum", symbol: "ETH", decimals: 10, totalSupply: 100000, type: .erc20),
                   hlq3Token(tokenId: "1", attributes: HyperlootToken.Attributes(description: "This is a rocket launcher", name: "Rocket Launcher", imageURL: "")),
                   hlq3Token(tokenId: "2", attributes: HyperlootToken.Attributes(description: "This is a plasma", name: "Plasma Gun", imageURL: "")),
                   HyperlootToken(cataloged: false, contractAddress: "0x9932", name: "Coin", symbol: "COIN", decimals: 0, totalSupply: 100000, type: .erc20)]
        
        buildDataSource(tokens: tokens)
        
        completion()
    }
    
    private func buildDataSource(tokens: [HyperlootToken]) {
        
        dataSource.removeAll()

        func erc721Items(address: String) -> [DashboardTokenItemInfoPresentation] {
            return tokens.filter { $0.contractAddress == address }.compactMap { (t) in
                if case .erc721(tokenId: _, attributes: let attributes) = t.type {
                    return DashboardTokenItemInfoPresentation(itemImageURL: attributes.imageURL,
                                                              itemName: attributes.name,
                                                              itemShortDescription: attributes.description,
                                                              itemPrice: BalanceFormatter.format(balance: "$10",
                                                                                                 fontHeight: 20.0,
                                                                                                 change: .up(value: "2.0"),
                                                                                                 changeFontHeight: 15.0))
                    
                }
                return nil
            }
        }

        tokens.forEach { (token) in
            let address = token.contractAddress
            
            if (dataSource.filter { $0.sectionId == address }.first) == nil {
                let items: [DashboardTokenItemInfoPresentation]
                var shouldHideSeparator: Bool
                
                switch token.type {
                case .erc20:
                    shouldHideSeparator = false
                    items = []
                case .erc721(tokenId: _, attributes: _):
                    shouldHideSeparator = true
                    items = erc721Items(address: address)
                }
                dataSource.append(DataSourceSection(sectionId: address,
                                                    presentation: DashboardTokenInfoSectionPresentation(tokenSymbol: token.symbol, tokenValue: "$1000", hideSeparator: shouldHideSeparator),
                                                    items: items))
            }
        }
    }
    
    // MARK: - Data Source
    
    public var balance: NSAttributedString {
        return BalanceFormatter.format(balance: "$3000", fontHeight: 34.0, change: .down(value: "20.0"), changeFontHeight: 20.0)
    }
    
    public func numberOfTokens() -> Int {
        return dataSource.count
    }
    
    public func numberOfItemsForToken(at index: Int) -> Int {
        return dataSource[index].items.count
    }

    public func presentationForToken(at index: Int) -> DashboardTokenInfoSectionPresentation {
        return dataSource[index].presentation
    }
    
    public func presentationForItem(at index: Int, section: Int) -> DashboardTokenItemInfoPresentation? {
        return dataSource[section].items[index]
    }
}
