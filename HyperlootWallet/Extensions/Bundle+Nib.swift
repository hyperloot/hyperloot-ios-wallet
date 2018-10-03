//
//  Bundle+Nib.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 10/1/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

public extension Bundle {
    
    class func view<T>(fromNib name: String? = nil, type: T.Type, owner: AnyObject? = nil) -> T {
        var fileName = name
        if name == nil {
            fileName = String(describing: type)
        }
        
        if let view = Bundle.main.loadNibNamed(fileName!, owner: owner, options: nil)?.first as? T {
            return view
        }
        
        fatalError("Could not load view with type " + String(describing: type))
    }
}
