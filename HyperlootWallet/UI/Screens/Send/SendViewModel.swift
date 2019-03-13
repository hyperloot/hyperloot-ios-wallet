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
        var speed: Speed = .regular
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
    
    public func send(to: String, amount: String?, completion: @escaping () -> Void) {
        let amountToSend: HyperlootSendAmount
        if asset.token.isERC721() {
            amountToSend = .uniqueToken
        } else {
            amountToSend = .amount(amount ?? "")
        }
        Hyperloot.shared.send(token: asset.token, to: to, amount: amountToSend) { (result) in
            switch result {
            case .success(let transaction):
                print(transaction)
            case .failure(let error):
                print(error)
            }
            
            completion()
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
    
    // MARK: - Actions
    
    private func validate(enteredAmount: String?) -> String {
        guard let amount = enteredAmount else {
            return ""
        }
        // TODO: check if value is above limit
        return amount
    }
    
    func didChangeAmount(value: String?) -> UpdateTextFieldResult {
        guard asset.token.isERC721() == false else {
            return .dontUpdate
        }
        
        let validatedValue = validate(enteredAmount: value)
        transactionInput.tokenInfo = .erc20(amount: validatedValue)
        
        return (validatedValue != value) ? .update(value: validatedValue) : .dontUpdate
    }
    
    func didPasteOrScan(address: String) -> UpdateTextFieldResult {
        guard let addressTo = Address(string: address)?.description else {
            return .dontUpdate
        }
        
        transactionInput.nickname = nil
        transactionInput.addressTo = addressTo
        
        return .update(value: addressTo)
    }
}
