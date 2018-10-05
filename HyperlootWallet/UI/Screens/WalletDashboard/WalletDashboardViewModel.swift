//
//  WalletDashboardViewModel.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 10/1/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

class WalletDashboardViewModel {
    
    struct TokensTree {
        let contractAddress: String
        let rootToken: HyperlootToken
        let tokens: [HyperlootToken]
    }
    
    private var tokensTree: [TokensTree] = []
    private var tokens: [HyperlootToken] = []
    
    public private(set) var selectedToken: HyperlootToken?
    
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
    
    // If the user taps on section (token info) then the app shows transactions history
    func didSelectTokenToShowTransactions(at index: Int) {
        let contract = tokensTree[index]
        selectedToken = contract.rootToken
    }
    
    func didSelectTokenToShowDetails(at index: Int, section: Int) {
        let contract = tokensTree[section]
        selectedToken = contract.tokens[index]
    }
    
    private func buildDataSource(tokens: [HyperlootToken]) {
        
        tokensTree.removeAll()
        
        tokens.forEach { (token) in
            let contractAddress = token.contractAddress
            guard (tokensTree.contains { (tree) in return contractAddress == tree.contractAddress }) == false else {
                return
            }
            
            
            var filteredTokens: [HyperlootToken] = []
            if isERC721(token: token) {
                filteredTokens = tokens.filter { $0.contractAddress == contractAddress }
            }
            
            tokensTree.append(TokensTree(contractAddress: contractAddress, rootToken: token, tokens: filteredTokens))
        }
    }
    
    private func isERC721(token: HyperlootToken) -> Bool {
        var isERC721: Bool = false
        if case .erc721(tokenId: _, attributes: _) = token.type {
            isERC721 = true
        }
        
        return isERC721
    }
    
    // MARK: - Data Source
    
    public var balance: NSAttributedString {
        return BalanceFormatter.format(balance: "$3000", fontHeight: 34.0, change: .down(value: "20.0"), changeFontHeight: 20.0)
    }
    
    public func numberOfSections() -> Int {
        return tokensTree.count
    }
    
    public func numberOfTokensInSection(at index: Int) -> Int {
        return tokensTree[index].tokens.count
    }

    public func presentationForToken(at index: Int) -> DashboardTokenInfoSectionPresentation {
        let token = tokensTree[index].rootToken
        return DashboardTokenInfoSectionPresentation(tokenSymbol: token.symbol,
                                                     tokenValue: "$1000",
                                                     hideSeparator: isERC721(token: token))
    }
    
    public func presentationForItem(at index: Int, section: Int) -> DashboardTokenItemInfoPresentation? {
        let token = tokensTree[section].tokens[index]
        guard case .erc721(tokenId: _, attributes: let attributes) = token.type else {
            return nil
        }
        return DashboardTokenItemInfoPresentation(itemImageURL: attributes.imageURL,
                                                  itemName: attributes.name,
                                                  itemShortDescription: attributes.description,
                                                  itemPrice: BalanceFormatter.format(balance: "$10",
                                                                                     fontHeight: 20.0,
                                                                                     change: .up(value: "2.0"),
                                                                                     changeFontHeight: 15.0))
    }
}
