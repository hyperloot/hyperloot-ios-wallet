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
    
    private var isLoadingWallet: Bool = false
    
    public private(set) var selectedToken: HyperlootToken?
    
    func loadWallet(completion: @escaping () -> Void) {

        guard isLoadingWallet == false else { return }
        
        isLoadingWallet = true
        
        var allTokens: [HyperlootToken] = []

        Hyperloot.shared.getBalance { [weak self] (token) in
            
            allTokens.append(token)
            
            Hyperloot.shared.getTokens { (tokens) in
                guard let strongSelf = self else { return }
                allTokens.append(contentsOf: tokens)
                strongSelf.tokens = allTokens
                
                strongSelf.buildDataSource(tokens: allTokens)
                completion()
                
                strongSelf.isLoadingWallet = false
            }
        }
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
                filteredTokens = tokens.filter { $0.contractAddress == contractAddress && hasTokenID(token: $0) }
            }
            
            tokensTree.append(TokensTree(contractAddress: contractAddress, rootToken: token, tokens: filteredTokens))
        }
    }
    
    private func isERC721(token: HyperlootToken) -> Bool {
        var isERC721: Bool = false
        if case .erc721 = token.type {
            isERC721 = true
        }
        
        return isERC721
    }
    
    private func hasTokenID(token: HyperlootToken) -> Bool {
        if case .erc721(tokenId: let tokenId, totalCount: _, attributes: _) = token.type {
            return tokenId != HyperlootToken.Constants.noTokenId
        }
    
        return false
    }
    
    // MARK: - Data Source
    
    public var balance: NSAttributedString {
        guard let user = Hyperloot.shared.user else {
            return NSAttributedString(string: "")
        }
        return NSAttributedString(string: "\(user.nickname.name)#\(user.nickname.identifier)")
//        return BalanceFormatter.format(balance: "$3000", fontHeight: 34.0, change: .down(value: "20.0"), changeFontHeight: 20.0)
    }
    
    public func numberOfSections() -> Int {
        return tokensTree.count
    }
    
    public func numberOfTokensInSection(at index: Int) -> Int {
        return tokensTree[index].tokens.count
    }

    public func presentationForToken(at index: Int) -> DashboardTokenInfoSectionPresentation {
        let currentTokensTree = tokensTree[index]
        let token = currentTokensTree.rootToken
        var value: String = ""
        switch token.type {
        case .erc20(amount: let amount):
            value = TokenFormatter.erc20Value(formattedValue: amount, symbol: token.symbol)
        case .erc721(tokenId: _, totalCount: let totalCount, attributes: _):
            value = TokenFormatter.erc721Total(count: totalCount)
        }
        let shouldHideSeparator = isERC721(token: token) && currentTokensTree.tokens.isEmpty == false
        return DashboardTokenInfoSectionPresentation(tokenSymbol: TokenFormatter.tokenDisplay(name: token.name, symbol: token.symbol),
                                                     tokenValue: value,
                                                     hideSeparator: shouldHideSeparator)
    }
    
    public func presentationForItem(at index: Int, section: Int) -> DashboardTokenItemInfoPresentation? {
        let token = tokensTree[section].tokens[index]
        guard isERC721(token: token), hasTokenID(token: token),
            case .erc721(tokenId: let tokenId, totalCount: _, attributes: let attributes) = token.type else {
            return nil
        }
        return DashboardTokenItemInfoPresentation(itemImageURL: attributes.imageURL,
                                                  itemName: attributes.name,
                                                  itemShortDescription: attributes.description,
                                                  itemPrice: NSAttributedString(string: tokenId))
    }
}
