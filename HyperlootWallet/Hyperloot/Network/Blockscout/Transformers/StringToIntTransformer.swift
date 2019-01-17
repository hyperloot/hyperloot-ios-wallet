//
//  StringToIntTransformer.swift
//  HyperlootWallet
//
//  Created by valery_vaskabovich on 12/5/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import ObjectMapper

class StringToIntTransformer: TransformType {
    public typealias Object = Int
    public typealias JSON = String
    
    public init() {}
    
    open func transformFromJSON(_ value: Any?) -> Int? {
        if let string = value as? String {
            return Int(string)
        } else if let number = value as? Int {
            return number
        }
        return nil
    }
    
    open func transformToJSON(_ value: Int?) -> String? {
        guard let value = value else { return nil }
        return value.description
    }
}
