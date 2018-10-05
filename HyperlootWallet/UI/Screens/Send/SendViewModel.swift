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
        
        enum TokenInfoType {
            case regularToken(presentation: SendTokenDetailsPresentation)
            case tokenItem(presentation: SendTokenItemDetailsPresentation)
        }
        
        let hideRegularTokenDetails: Bool
        let hideTokenItemDetails: Bool
        let tokenInfoType: TokenInfoType
    }
 
    let token: HyperlootToken
    
    required init(token: HyperlootToken) {
        self.token = token
    }
    
    private func tokenInfo() -> (hideRegularTokenDetails: Bool, hideTokenItemDetails: Bool, tokenInfoType: Presentation.TokenInfoType) {
        var hideRegularTokenDetails = true
        var hideTokenItemDetails = true
        var tokenInfoType: Presentation.TokenInfoType
        
        switch token.type {
        case .erc20:
            hideRegularTokenDetails = false
            tokenInfoType = .regularToken(presentation: SendTokenDetailsPresentation(tokenSymbol: token.symbol,
                                                                                     amountPlaceholderText: "Amount"))
        case .erc721(tokenId: _, attributes: let attributes):
            hideTokenItemDetails = false
            tokenInfoType = .tokenItem(presentation: SendTokenItemDetailsPresentation(imageURL: attributes.imageURL,
                                                                                      name: attributes.name,
                                                                                      description: attributes.description))
        }
        return (hideRegularTokenDetails: hideRegularTokenDetails, hideTokenItemDetails: hideTokenItemDetails, tokenInfoType: tokenInfoType)
    }
    
    var presentation: Presentation {
        let tokenInfo = self.tokenInfo()
        return Presentation(hideRegularTokenDetails: tokenInfo.hideRegularTokenDetails,
                            hideTokenItemDetails: tokenInfo.hideTokenItemDetails,
                            tokenInfoType: tokenInfo.tokenInfoType)
    }
}
