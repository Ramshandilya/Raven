//
//  BaseOperation.swift
//  Raven
//
//  Created by Ramsundar Shandilya on 4/3/18.
//  Copyright © 2018 Ramsundar Shandilya. All rights reserved.
//

import Foundation

open class BaseOperation: Operation {
    
    override open var isAsynchronous: Bool {
        return true
    }
    
    //Executing
    private var _executing: Bool = false
    override open var isExecuting: Bool {
        get { return _executing }
        set {
            willChangeValue(forKey: "isExecuting")
            _executing = newValue
            didChangeValue(forKey: "isExecuting")
            if _cancelled == true {
                self.isFinished = true
            }
        }
    }
    
    //Finished
    private var _finished: Bool = false
    override open var isFinished: Bool {
        get { return _finished }
        set {
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }
    
    //Cancelled
    private var _cancelled: Bool = false
    override open var isCancelled: Bool {
        get { return _cancelled }
        set {
            willChangeValue(forKey: "isCancelled")
            _cancelled = newValue
            didChangeValue(forKey: "isCancelled")
        }
    }
    
    private(set) var observers = [OperationObserver]()
    func addObserver(observer: OperationObserver) {
        assert(!isExecuting, "Cannot modify observers after execution has begun.")
        
        observers.append(observer)
    }
    
    public final override func start() {
        super.start()
        isExecuting = true
    }
    
    public final override func main() {
        if isCancelled {
            isExecuting = false
            isFinished = true
            return
        }
        
        for observer in observers {
            observer.operationDidStart(self)
        }
        
        execute()
    }
    
    open func execute() {
        assertionFailure("execute() must be overriden")
        finish()
    }
    
    public final func finish(errors: [Error] = []) {
        self.isFinished = true
        self.isExecuting = false
        
        for observer in observers {
            observer.operationDidFinish(self, errors: errors)
        }
    }
    
    open override func cancel() {
        super.cancel()
        
        isCancelled = true
        
        if isExecuting {
            isExecuting = false
            isFinished = true
        }
    }
}
