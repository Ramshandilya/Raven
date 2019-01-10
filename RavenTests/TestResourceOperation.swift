//
//  TestResourceOperation.swift
//  RavenTests
//
//  Created by Ramsundar Shandilya on 7/31/18.
//  Copyright © 2018 Ramsundar Shandilya. All rights reserved.
//

import Foundation
@testable import Raven

enum TestEndpoint: String {
    case success = "/5b60b0712f00002c00461a7a"
    case clientError = "/5b60b7462f0000dd3e461a94"
    case serverError = "/5b60b76a2f00002c00461a95"
    case parsingError = "/5b60c9cc2f0000cb3e461adf"
}

class TestResourceOperation: NetworkOperation {
    
    init(endPoint: TestEndpoint, service: NetworkService, completion: NetworkOperationCompletion) {
        let coinRequest = Request(endpoint: endPoint.rawValue, method: .get)
        
        super.init(request: coinRequest, service: service)
        self.completion = completion
    }
    
}
