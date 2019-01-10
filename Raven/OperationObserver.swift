//
//  OperationObserver.swift
//  Raven
//
//  Created by Ramsundar Shandilya on 4/3/18.
//  Copyright © 2018 Ramsundar Shandilya. All rights reserved.
//

import Foundation

/// A protocol that types may implement if they wish to be notified of significant operation lifecycle events.
protocol OperationObserver {
    
    /// Invoked immediately prior to the `Operation`'s `execute()` method.
    func operationDidStart(_ operation: BaseOperation)
    
    /// Invoked as an `Operation` finishes, along with any errors produced during execution (or readiness evaluation).
    func operationDidFinish(_ operation: BaseOperation, errors: [Error])
}
