//
//  SendViewModel.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 10/4/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

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
    
    struct TransactionInput {
        enum TokenInfo {
            case erc721(tokenId: String)
            case erc20(amount: String)
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
 
    let token: HyperlootToken
    var transactionInput: TransactionInput
    
    required init(token: HyperlootToken) {
        self.token = token
        self.transactionInput = TransactionInput(tokenInfo: nil, nickname: nil, addressTo: nil, speed: .regular)
    }
    
    private func tokenPresentationInfo() -> (hideRegularTokenDetails: Bool, hideTokenItemDetails: Bool, tokenPresentationType: Presentation.TokenPresentationType) {
        var hideRegularTokenDetails = true
        var hideTokenItemDetails = true
        var tokenPresentationType: Presentation.TokenPresentationType
        
        switch token.type {
        case .ether:
            fallthrough
        case .erc20:
            hideRegularTokenDetails = false
            tokenPresentationType = .regularToken(presentation: SendTokenDetailsPresentation(tokenSymbol: token.symbol,
                                                                                             amountPlaceholderText: "Amount"))
        case .erc721(tokenId: _, totalCount: _, attributes: let attributes):
            hideTokenItemDetails = false
            tokenPresentationType = .tokenItem(presentation: SendTokenItemDetailsPresentation(imageURL: attributes.imageURL,
                                                                                              name: attributes.name,
                                                                                              description: attributes.description))
        }
        return (hideRegularTokenDetails: hideRegularTokenDetails, hideTokenItemDetails: hideTokenItemDetails, tokenPresentationType: tokenPresentationType)
    }
    
    var presentation: Presentation {
        let tokenPresentationInfo = self.tokenPresentationInfo()
        return Presentation(hideRegularTokenDetails: tokenPresentationInfo.hideRegularTokenDetails,
                            hideTokenItemDetails: tokenPresentationInfo.hideTokenItemDetails,
                            tokenPresentationType: tokenPresentationInfo.tokenPresentationType)
    }
}
