//
//  OperationQueue+Completion.swift
//  HyperlootWallet
//
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
