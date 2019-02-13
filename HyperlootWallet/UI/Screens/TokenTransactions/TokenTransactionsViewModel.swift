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
        let balanceInCurrency: NSAttributedString
        let balanceInCrypto: String
        let walletAddress: String
    }
    
    let token: HyperlootToken
    var transactions: [HyperlootTransaction] = []
    
    var transactionPresentations: [TransactionCellPresentation] = []
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
        return dateFormatter
    } ()
    
    init(token: HyperlootToken) {
        self.token = token
    }
    
    public func load(completion: @escaping () -> Void) {
        
        Hyperloot.shared.getTransactions(type: transactionsType, page: 0) { [weak self] (transactions) in
            guard let strongSelf = self else { return }
            strongSelf.transactionPresentations.removeAll()
            
            transactions.forEach {
                let date = strongSelf.dateFormatter.string(from: Date(timeIntervalSince1970: $0.timestamp))
                let presentation = TransactionCellPresentation(date: date,
                                                               tokenValue: strongSelf.value(from: $0),
                                                               showTransactionValueSign: strongSelf.shouldShowTransactionSign(for: $0),
                                                               transactionHash: $0.transactionHash)
                strongSelf.transactionPresentations.append(presentation)
            }
            completion()
        }
    }
    
    private var transactionsType: HyperlootTransactionType {
        let contractAddress = token.contractAddress
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
    
    private func value(from transaction: HyperlootTransaction) -> BalanceFormatter.TransactionAmount {
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
        
        return TokenFormatter.isTo(walletAddress: walletAddress, transaction: transaction)
            ? BalanceFormatter.TransactionAmount.positive(value: transactionValue)
            : BalanceFormatter.TransactionAmount.negative(value: transactionValue)
    }
    
    private var walletAddress: String {
        return Hyperloot.shared.currentWallet()?.addressString ?? ""
    }
    
    private var balanceInCurrency: String {
        switch token.type {
        case .ether(amount: let amount):
            fallthrough
        case .erc20(amount: let amount):
            return TokenFormatter.erc20Value(formattedValue: amount, symbol: token.symbol)
        case .erc721(tokenId: _, totalCount: let totalCount, attributes: _):
            return TokenFormatter.erc721NameAndTotal(count: totalCount, tokenName: token.name)
        }
    }
    
    private var title: String {
        return "\(token.name) - \(token.symbol)"
    }
    
    var presentation: Presentation {
        return Presentation(title: title,
                            balanceInCurrency: NSAttributedString(string: balanceInCurrency),//BalanceFormatter.format(balance: balanceInCurrency, fontHeight: 34.0, change: .up(value: "10.0"), changeFontHeight: 20.0),
                            balanceInCrypto: "",//"Ξ 2.000 x $400",
                            walletAddress: walletAddress)
    }
    
    // MARK: - Transactions history
    public func numberOfTransactions() -> Int {
        return transactionPresentations.count
    }
    
    public func transaction(at index: Int) -> TransactionCellPresentation {
        return transactionPresentations[index]
    }
}
