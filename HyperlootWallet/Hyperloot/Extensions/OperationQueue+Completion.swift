//
//  OperationQueue+Completion.swift
//  HyperlootWallet
//
//  Created by valery_vaskabovich on 12/13/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

extension OperationQueue {
    
    func onCompletion(block: @escaping () -> Void) {
        guard operations.count > 0 else {
            block()
            return
        }
        let doneOperation = BlockOperation {
            DispatchQueue.main.async {
                block()
            }
        }
        operations.forEach { doneOperation.addDependency($0) }
        
        addOperation(doneOperation)
    }
}
