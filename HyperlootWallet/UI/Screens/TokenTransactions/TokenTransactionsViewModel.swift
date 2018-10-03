//
//  TokenTransactionsViewModel.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 10/2/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

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
    
    init(token: HyperlootToken) {
        self.token = token
    }
    
    public func load(completion: @escaping () -> Void) {
        transactions = [ HyperlootTransaction(transactionHash: "0x123412341234214431", contractAddress: token.contractAddress, timestamp: Date().timeIntervalSince1970 - 86400, from: walletAddress, to: "0x54231234F123", status: .success, value: "$10") ,
                         HyperlootTransaction(transactionHash: "0x123412341234214431", contractAddress: token.contractAddress, timestamp: Date().timeIntervalSince1970 - 24000, from: "0x123541234", to: walletAddress, status: .success, value: "$10") ]
        
        transactionPresentations.removeAll()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
        transactions.forEach {
            let value = $0.from == walletAddress ? BalanceFormatter.TransactionAmount.negative(value: $0.value) : BalanceFormatter.TransactionAmount.positive(value: $0.value)
            let date = dateFormatter.string(from: Date(timeIntervalSince1970: $0.timestamp))
            let presentation = TransactionCellPresentation(date: date,
                                                           tokenValue: value,
                                                           transactionHash: $0.transactionHash)
            transactionPresentations.append(presentation)
        }
    }
    
    private var walletAddress: String {
        return Hyperloot.shared.currentWallet()?.address.eip55String ?? ""
    }
    
    private var balanceInCurrency: String {
        return "$800.0"
    }
    
    private var title: String {
        return "\(token.symbol) - \(balanceInCurrency)"
    }
    
    var presentation: Presentation {
        return Presentation(title: title,
                            balanceInCurrency: BalanceFormatter.format(balance: balanceInCurrency, fontHeight: 34.0, change: .up(value: "10.0"), changeFontHeight: 20.0),
                            balanceInCrypto: "Ξ 2.000 x $400",
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
