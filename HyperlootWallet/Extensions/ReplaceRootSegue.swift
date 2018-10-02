//
//  ReplaceRootSegue.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 9/27/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit

class ReplaceRootSegue: UIStoryboardSegue {
    
    override func perform() {
        self.source.dismiss(animated: false, completion: nil)
        UIApplication.shared.keyWindow?.rootViewController = self.destination
    }
}
