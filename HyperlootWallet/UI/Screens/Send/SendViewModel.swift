//
//  SendViewModel.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import TrustCore

class SendViewModel {
    
    struct Presentation {
        enum TokenPresentationType {
            case regularToken(presentation: SendTokenDetailsPresentation)
            case tokenItem(presentation: SendTokenItemDetailsPresentation)
        }
        
        let hideRegularTokenDetails: Bool
        let hideTokenItemDetails: Bool
        let tokenPresentationType: TokenPresentationType
    }
    
    enum ValidationError: String {
        case amount = "Amount"
        case address = "Address"
    }
    
    enum UpdateTextFieldResult {
        case dontUpdate
        case update(value: String)
    }
    
    struct TransactionInput {
        enum TokenInfo {
            case erc721(tokenId: String)
            case erc20(amount: String)
            
            init(asset: WalletAsset) {
                switch asset.value {
                case .erc20, .ether:
                    self = .erc20(amount: "")
                case .erc721(tokenId: let tokenId, totalCount: _, attributes: _):
                    self = .erc721(tokenId: tokenId)
                }
            }
        }
        
        enum Speed {
            case regular
            case fast
        }
        
        var tokenInfo: TokenInfo?
        var nickname: String?
        var addressTo: String?
        var speed: Speed = .fast
    }
 
    let asset: WalletAsset
    var transactionInput: TransactionInput
    
    required init(asset: WalletAsset) {
        self.asset = asset
        self.transactionInput = TransactionInput(tokenInfo: TransactionInput.TokenInfo(asset: asset),
                                                 nickname: nil,
                                                 addressTo: nil,
                                                 speed: .regular)
    }
    
    enum SendResult {
        case success(transactionHash: String)
        case error(HyperlootTransactionSendError)
    }
    
    public func send(completion: @escaping (SendResult) -> Void) {
        guard let tokenInfo = transactionInput.tokenInfo, let addressTo = transactionInput.addressTo else {
            completion(.error(.validationFailed))
            return
        }
        
        let amountToSend: HyperlootSendAmount
        switch tokenInfo {
        case .erc20(amount: let amount): amountToSend = .amount(amount)
        case .erc721: amountToSend = .uniqueToken
        }
        
        Hyperloot.shared.send(token: asset.token, to: addressTo, amount: amountToSend) { (result) in
            switch result {
            case .success(let transaction):
                completion(.success(transactionHash: transaction.transactionHash))
            case .failure(let error):
                completion(.error(error))
            }
        }
    }
    
    private func tokenPresentationInfo() -> (hideRegularTokenDetails: Bool, hideTokenItemDetails: Bool, tokenPresentationType: Presentation.TokenPresentationType) {
        var hideRegularTokenDetails = true
        var hideTokenItemDetails = true
        var tokenPresentationType: Presentation.TokenPresentationType
        
        switch asset.value {
        case .ether(amount: let amount):
            fallthrough
        case .erc20(amount: let amount):
            hideRegularTokenDetails = false
            let presentation = SendTokenDetailsPresentation(icon: .none,
                                                            tokenSymbol: asset.token.symbol,
                                                            amountPlaceholderText: "Amount to send",
                                                            totalAvailableAmount: amount)
            tokenPresentationType = .regularToken(presentation: presentation)
        case .erc721(tokenId: let tokenId, totalCount: _, attributes: let attributes):
            hideTokenItemDetails = false
            let presentation = SendTokenItemDetailsPresentation(imageURL: attributes?.imageURL,
                                                                name: TokenFormatter.erc721Token(itemName: attributes?.name, tokenName: asset.token.name, tokenId: tokenId),
                                                                description: attributes?.description ?? "#\(tokenId)",
                                                                price: TokenFormatter.formattedPrice(doubleValue: asset.totalPrice))
            tokenPresentationType = .tokenItem(presentation: presentation)
        }
        return (hideRegularTokenDetails: hideRegularTokenDetails, hideTokenItemDetails: hideTokenItemDetails, tokenPresentationType: tokenPresentationType)
    }
    
    var presentation: Presentation {
        let tokenPresentationInfo = self.tokenPresentationInfo()
        return Presentation(hideRegularTokenDetails: tokenPresentationInfo.hideRegularTokenDetails,
                            hideTokenItemDetails: tokenPresentationInfo.hideTokenItemDetails,
                            tokenPresentationType: tokenPresentationInfo.tokenPresentationType)
    }
    
    public func validate() -> [ValidationError] {
        var errors: [ValidationError] = []
        
        guard let tokenInfo = transactionInput.tokenInfo else {
            return [.amount]
        }
        switch tokenInfo {
        case .erc20(amount: let amount):
            if isValid(amount: amount) == false {
                errors.append(.amount)
            }
        case .erc721: break
        }
        
        if Address(string: transactionInput.addressTo ?? "") == nil {
            errors.append(.address)
        }
        
        return errors
    }
    
    public func errorMessage(sendError: HyperlootTransactionSendError) -> String {
        switch sendError {
        case .failedToSend:
            return "There was a problem during sending your assets. Please try again later."
        case .failedToSignTransaction:
            return "Unfortunately we weren't be able to sign your transaction. Please try again later."
        case .insufficientBalance:
            return "Unfortunately you don't have enough balance to send this transaction. Please check the amount you've entered and try again later."
        case .invalidNonceOrGasInfo:
            return "There was an issue with the gas station. Please try again."
        case .validationFailed:
            return "Transaction is not valid. Please fill the required information and try again later."
        }
    }
    
    // MARK: - Actions
    func didChangeAmount(value: String?) -> UpdateTextFieldResult {
        guard asset.token.isERC721() == false else {
            return .dontUpdate
        }
        
        let validatedValue = validate(enteredAmount: value)
        transactionInput.tokenInfo = .erc20(amount: validatedValue)
        
        return (validatedValue != value) ? .update(value: validatedValue) : .dontUpdate
    }
    
    enum AddressSource {
        case manual
        case paste
        case scan
    }
    
    func update(address: String, source: AddressSource) -> UpdateTextFieldResult {
        let addressTo = Address(string: address)?.description
        if addressTo != nil || source == .manual {
            transactionInput.nickname = nil
            transactionInput.addressTo = addressTo
            
            return .update(value: addressTo ?? address)
        }
        
        return .dontUpdate
    }
    
    func canChange(amount: String?, in range: NSRange, with string: String) -> Bool {
        guard string.isEmpty == false else {
            return true
        }
        let newAmount = (amount ?? "") as NSString
        let newString = newAmount.replacingCharacters(in: range, with: string)
        return newString.range(of: "^[0-9]+[.]?[0-9]*$", options: .regularExpression) != nil
    }
    
    // MARK: - Private
    
    private func isValid(amount: String) -> Bool {
        return amount.range(of: "^[0-9]+([.][0-9]+)?$", options: .regularExpression) != nil
    }
    
    private func validate(enteredAmount: String?) -> String {
        guard let amount = enteredAmount, isValid(amount: amount) else {
            return ""
        }
        
        let maxTokenAmount: String
        switch asset.value {
        case .erc20(amount: let availableAmount):
            maxTokenAmount = availableAmount
        case .ether(amount: let availableAmount):
            maxTokenAmount = availableAmount
        case .erc721:
            maxTokenAmount = "0"
        }
        
        let formatter = EtherNumberFormatter.full
        
        guard let enteredAmount = formatter.number(from: amount, decimals: asset.token.decimals),
            let maxAmount = formatter.number(from: maxTokenAmount, decimals: asset.token.decimals) else {
                return amount
        }
        
        if enteredAmount > maxAmount {
            return formatter.string(from: maxAmount, decimals: asset.token.decimals)
        }
        
        return amount
    }
}
