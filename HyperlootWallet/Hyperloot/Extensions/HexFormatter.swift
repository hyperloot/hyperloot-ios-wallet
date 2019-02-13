//
//  HexFormatter.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation
import BigInt

extension String {
    func add0x() -> String {
       return "0x\(self)"
    }
    
    func remove0x() -> String {
        if hasPrefix("0x") {
            return String(dropFirst(2))
        }
        return self
    }
}

extension BigInt {
    init?(hexString: String?) {
        guard let stringValue = hexString?.remove0x() else {
            return nil
        }
        self.init(stringValue, radix: 16)
    }
    
    var hexString: String {
        return String(self, radix: 16).add0x() // "0x" + hex value
    }
}

extension Data {
    var hexString: String {
        let hexValue = map { String(format: "%02hhx", $0) }.joined()
        return hexValue.add0x()
    }
}
