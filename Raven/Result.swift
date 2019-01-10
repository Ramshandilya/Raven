//
//  Result.swift
//  Raven
//
//  Created by Ramsundar Shandilya on 4/3/18.
//  Copyright © 2018 Ramsundar Shandilya. All rights reserved.
//

import Foundation

/**
 A generic result type.
 
 - Success: Wraps with the generic value.
 - Failure: Wraps with an error type.
 */
public enum Result<Value> {
    case success(Value)
    case failure(Error)
}

//Convenience
//http://www.cocoawithlove.com/blog/2016/08/21/result-types-part-one.html
public extension Result {
    
    var value: Value? {
        switch self {
        case .success(let val):
            return val
        case .failure:
            return nil
        }
    }
    
    var error: Error? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
    
    var isError: Bool {
        switch self {
        case .success:
            return false
        case .failure:
            return true
        }
    }
}
