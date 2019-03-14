//
//  TokenTransactionsViewModel.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import BigInt

class TokenTransactionsViewModel {
    
    struct Presentation {
        let title: String
        let tableHeaderTitle: String
    }
    
    let asset: WalletAsset
    var transactions: [HyperlootTransaction] = []
    var inventory: [HyperlootToken] = []
    
    var transactionPresentations: [TransactionCellPresentation] = []
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    } ()
    
    init(asset: WalletAsset) {
        self.asset = asset
    }
    
    public func load(completion: @escaping () -> Void) {

        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        Hyperloot.shared.getCachedInventory { [weak self] (tokens) in
            self?.inventory = tokens
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        Hyperloot.shared.getTransactions(type: transactionsType, page: 0) { [weak self] (transactions) in
            guard let strongSelf = self else { return }
            strongSelf.transactionPresentations.removeAll()
            
            transactions.forEach {
                let date = strongSelf.dateFormatter.string(from: Date(timeIntervalSince1970: $0.timestamp))
                let presentation = TransactionCellPresentation(date: date,
                                                               tokenValue: strongSelf.priceInCurrency(from: $0),
                                                               details: strongSelf.value(from: $0),
                                                               image: strongSelf.image)
                strongSelf.transactionPresentations.append(presentation)
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
    
    private func attributes(tokenId: String) -> HyperlootToken.Attributes? {
        return inventory
            .map { (token) -> HyperlootToken.Attributes? in
                guard case .erc721(tokenId: let foundTokenId, totalCount: _, attributes: let attributes) = token.type,
                    tokenId == foundTokenId else {
                        return nil
                }
                return attributes
            }
            .compactMap { $0 }
            .first
    }
    
    private var image: TransactionCellPresentation.Image {
        switch asset.value {
        case .erc20, .ether:
            return .none
        case .erc721(tokenId: let tokenId, totalCount: _, attributes: _):
            let imageURL = attributes(tokenId: tokenId)?.imageURL
            return .imageURL(imageURL)
        }
    }
    
    private var transactionsType: HyperlootTransactionType {
        let contractAddress = asset.token.contractAddress
        if contractAddress == TokenConstants.Ethereum.ethereumContract {
            return .transactions
        }
        
        return .tokens(contractAddress: contractAddress)
    }
    
    private func priceInCurrency(from transaction: HyperlootTransaction) -> BalanceFormatter.TransactionAmount {
        var transactionPrice: String = ""

        var tokensAmount: Double = 0.0
        switch transaction.value {
        case .ether(value: let value):
            tokensAmount = TokenFormatter.erc20BalanceToDouble(from: value, decimals: TokenConstants.Ethereum.ethereumDecimals)
        case .token(value: let value, decimals: let decimals, _):
            tokensAmount = TokenFormatter.erc20BalanceToDouble(from: value, decimals: decimals)
        case .uniqueToken(_):
            tokensAmount = 1.0
        }
        
        let assetPrice = asset.price?.price ?? 0.0
        let total = assetPrice * tokensAmount
        transactionPrice = TokenFormatter.formattedPrice(doubleValue: total)
        
        return TokenFormatter.isTo(walletAddress: walletAddress, transaction: transaction)
            ? BalanceFormatter.TransactionAmount.positive(value: transactionPrice)
            : BalanceFormatter.TransactionAmount.negative(value: transactionPrice)
    }
    
    private func value(from transaction: HyperlootTransaction) -> String {
        var transactionValue: String = ""
        
        
        switch transaction.value {
        case .ether(value: let value):
            transactionValue = TokenFormatter.erc20Value(from: value,
                                                         decimals: TokenConstants.Ethereum.ethereumDecimals,
                                                         symbol: TokenConstants.Ethereum.ethereumSymbol)
        case .token(value: let value, decimals: let decimals, let symbol):
            transactionValue = TokenFormatter.erc20Value(from: value, decimals: decimals, symbol: symbol)
        case .uniqueToken(tokenId: let tokenId):
            let itemName = attributes(tokenId: tokenId)?.name
            transactionValue = TokenFormatter.erc721Token(itemName: itemName, tokenName: asset.token.name, tokenId: tokenId)
        }
        
        return transactionValue
    }
    
    private var walletAddress: String {
        return Hyperloot.shared.currentWallet()?.addressString ?? ""
    }
    
    private var title: String {
        return "\(asset.token.name) - \(asset.token.symbol)"
    }
    
    private var tableHeaderTitle: String {
        return (asset.assetType == .gameAsset) ? "Game asset" : "Currency"
    }
    
    var presentation: Presentation {
        return Presentation(title: title,
                            tableHeaderTitle: tableHeaderTitle)
    }
    
    // MARK: - Transactions history
    public func numberOfTransactions() -> Int {
        return transactionPresentations.count
    }
    
    public func transaction(at index: Int) -> TransactionCellPresentation {
        return transactionPresentations[index]
    }
}
