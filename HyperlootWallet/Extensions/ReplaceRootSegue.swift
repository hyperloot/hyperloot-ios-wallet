//
//  ReplaceRootSegue.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

class ReplaceRootSegue: UIStoryboardSegue {
    
    override func perform() {
        self.source.dismiss(animated: false, completion: nil)
        UIApplication.shared.keyWindow?.rootViewController = self.destination
    }
}
