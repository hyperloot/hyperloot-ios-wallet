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
    
    var transactionPresentations: [TransactionCellPresentation] = []
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    } ()
    
    private lazy var priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = NSLocale.current
        return formatter
    } ()
    
    init(asset: WalletAsset) {
        self.asset = asset
    }
    
    public func load(completion: @escaping () -> Void) {
        
        Hyperloot.shared.getTransactions(type: transactionsType, page: 0) { [weak self] (transactions) in
            guard let strongSelf = self else { return }
            strongSelf.transactionPresentations.removeAll()
            
            transactions.forEach {
                let date = strongSelf.dateFormatter.string(from: Date(timeIntervalSince1970: $0.timestamp))
                let presentation = TransactionCellPresentation(date: date,
                                                               tokenValue: strongSelf.priceInCurrency(from: $0),
                                                               showTransactionValueSign: strongSelf.shouldShowTransactionSign(for: $0),
                                                               details: strongSelf.value(from: $0))
                strongSelf.transactionPresentations.append(presentation)
            }
            completion()
        }
    }
    
    private var transactionsType: HyperlootTransactionType {
        let contractAddress = asset.token.contractAddress
        if contractAddress == TokenConstants.Ethereum.ethereumContract {
            return .transactions
        }
        
        return .tokens(contractAddress: contractAddress)
    }
    
    private func shouldShowTransactionSign(for transaction: HyperlootTransaction) -> Bool {
        if case .uniqueToken = transaction.value {
            return false
        }
        
        return true
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
        transactionPrice = priceFormatter.string(from: NSNumber(value: total)) ?? "0.0"
        
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
            transactionValue = TokenFormatter.erc721Value(tokenId: tokenId)
        }
        
        return transactionValue
    }
    
    private var walletAddress: String {
        return Hyperloot.shared.currentWallet()?.addressString ?? ""
    }
    
    private var balanceInCurrency: String {
        switch asset.value {
        case .ether(amount: let amount):
            fallthrough
        case .erc20(amount: let amount):
            return TokenFormatter.erc20Value(formattedValue: amount, symbol: asset.token.symbol)
        case .erc721(tokenId: _, totalCount: let totalCount, attributes: _):
            return TokenFormatter.erc721NameAndTotal(count: totalCount, tokenName: asset.token.name)
        }
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
