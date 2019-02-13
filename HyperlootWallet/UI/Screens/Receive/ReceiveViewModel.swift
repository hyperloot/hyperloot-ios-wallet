//
//  ReceiveViewModel.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

class ReceiveViewModel {
    
    struct Presentation {
        let qrCodeImage: UIImage?
        let walletAddress: String
    }
    
    public var walletAddress: String {
        return Hyperloot.shared.currentWallet()?.address.eip55String ?? ""
    }

    var presentation: Presentation {
        return Presentation(qrCodeImage: QRCodeImageGenerator.generate(from: walletAddress),
                            walletAddress: walletAddress)
    }
}
