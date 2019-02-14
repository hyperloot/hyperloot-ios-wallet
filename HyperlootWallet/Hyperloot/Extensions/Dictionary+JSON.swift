//
//  Dictionary+JSON.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

extension Dictionary {
    public func toJSONString(prettyPrint: Bool = false) -> String? {
        let options: JSONSerialization.WritingOptions = prettyPrint ? .prettyPrinted : []
        if let JSON = toJSONData(options: options) {
            return String(data: JSON, encoding: String.Encoding.utf8)
        }
        
        return nil
    }

    /// Converts an Object to JSON data with options
    private func toJSONData(options: JSONSerialization.WritingOptions = []) -> Data? {
        if JSONSerialization.isValidJSONObject(self) {
            let JSONData: Data?
            do {
                JSONData = try JSONSerialization.data(withJSONObject: self, options: options)
            } catch let error {
                print(error)
                JSONData = nil
            }
            
            return JSONData
        }
        
        return nil
    }
}
