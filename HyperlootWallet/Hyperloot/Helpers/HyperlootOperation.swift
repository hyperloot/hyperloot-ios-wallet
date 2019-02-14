//
//  HyperlootOperation.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

class HyperlootOperation: Operation {
    
    private var inProgress = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isExecuting: Bool {
        return inProgress
    }
    
    private var isDone = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isFinished: Bool {
        return isDone
    }
    
    func run() {
        self.inProgress = true
    }
    
    func done() {
        self.inProgress = false
        self.isDone = true
    }

}
