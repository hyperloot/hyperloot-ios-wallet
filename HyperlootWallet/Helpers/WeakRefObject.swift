//
//  WeakRefObject.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 10/17/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

class WeakRefValue<T> {
    
    private weak var weakObj: AnyObject?
    
    init(value: T) {
        weakObj = value as AnyObject
    }
    
    var value: T? {
        if let value = weakObj as? T {
            return value
        }
        
        return nil
    }
}

class WeakRefArray<T> {
    
    private var values: [WeakRefValue<T>] = []
    
    public func add(_ value: T) {
        values.append(WeakRefValue(value: value))
    }
    
    private func compact() {
        values = values.filter { $0.value != nil }
    }
    
    public func allValues() -> [T] {
        compact()
        return values.compactMap { $0.value }
    }
}
