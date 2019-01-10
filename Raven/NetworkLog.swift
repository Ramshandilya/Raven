//
//  NetworkLog.swift
//  Raven
//
//  Created by Ramsundar Shandilya on 7/31/18.
//  Copyright © 2018 Ramsundar Shandilya. All rights reserved.
//

import Foundation

public struct NetworkLog {
    
    #if DEBUG
    public static var enableLog = true
    #else
    public static var enableLog = false
    #endif
    
    public static func debug(_ message: Any) {
        guard enableLog else { return }
        
        print(message)
    }
    
}
