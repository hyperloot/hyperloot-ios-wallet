//
//  Dictionary+Merge.swift
//  HyperlootWallet
//
//  Created by valery_vaskabovich on 12/4/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

extension Dictionary {
    
    public mutating func merge(with dictionary: Dictionary) {
        dictionary.forEach { updateValue($1, forKey: $0) }
    }
}
