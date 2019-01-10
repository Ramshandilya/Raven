//
//  Request.swift
//  Raven
//
//  Created by Ramsundar Shandilya on 4/2/18.
//  Copyright © 2018 Ramsundar Shandilya. All rights reserved.
//

import Foundation

typealias Headers = [String: String]

typealias Parameters = [String : Any?]

struct Request {
    
    var endpoint: String
    
    var method: HTTPMethod
    
    var parameters: Parameters?
    
    var body: Data?
    
    var urlParameters: Parameters?
    
    var headers: Headers?
    
    var cachePolicy: URLRequest.CachePolicy?
    
    var timeout: TimeInterval?
    
    var serverTrustPolicy: ServerTrustPolicy?
    
    init(endpoint: String, method: HTTPMethod) {
        self.endpoint = endpoint
        self.method = method
    }
}

extension Request: CustomDebugStringConvertible {
    var debugDescription: String {
        var description = "Endpoint: \(endpoint)\nMethod: \(method.rawValue)\n"
        
        if let parameters = parameters {
            description += "Parameters: \(parameters)\n"
        }
        if let body = body,
            let bodyString = String(data: body, encoding: .utf8) {
            description += "Body: \(bodyString)\n"
        }
        
        return description
    }
}
