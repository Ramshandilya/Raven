//
//  NetworkController.swift
//  Raven
//
//  Created by Ramsundar Shandilya on 7/17/18.
//  Copyright © 2018 Ramsundar Shandilya. All rights reserved.
//

import Foundation

final class NetworkController {
    private let queue: OperationQueue
    
    init() {
        queue = OperationQueue()
        queue.qualityOfService = .userInitiated
    }
    
    var bandwidth: Double {
        let completedOperations = queue.operations.filter{$0.isFinished}
        let totalBandwidth = completedOperations.reduce(0, { (total, op) -> Double in
            guard let networkOperation = op as? NetworkOperation else {
                return total + 0
            }
            return total + networkOperation.bandwidth
        })
        
        return totalBandwidth/Double(completedOperations.count)
    }
    
    func addOperation(_ operation: NetworkOperation) {
        operation.addObserver(observer: self)
        queue.addOperation(operation)
    }
 
}

extension NetworkController: OperationObserver {
    func operationDidStart(_ operation: BaseOperation) {
        
    }
    func operationDidFinish(_ operation: BaseOperation, errors: [Error]) {
        guard let networkOperation = operation as? NetworkOperation else {
            return
        }
        
        print("Bandwidth - \(networkOperation.bandwidth)")
    }
}
