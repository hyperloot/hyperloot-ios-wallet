//
//  QRCodeImageGenerator.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 10/4/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit
import CoreImage

class QRCodeImageGenerator {
    
    struct Constants {
        static let scale: CGFloat = 7.0
    }
    
    static func generate(from string: String) -> UIImage? {
        let context = CIContext()
        let data = string.data(using: String.Encoding.ascii)
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        filter.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: Constants.scale, y: Constants.scale)
        guard let output = filter.outputImage?.transformed(by: transform),
            let cgImage = context.createCGImage(output, from: output.extent) else {
                return nil
        }
        return UIImage(cgImage: cgImage)
    }
}
