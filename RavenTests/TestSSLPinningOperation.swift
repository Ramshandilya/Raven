//
//  TestSSLPinningOperation.swift
//  RavenTests
//
//  Created by Ramsundar Shandilya on 8/1/18.
//  Copyright © 2018 Ramsundar Shandilya. All rights reserved.
//

import Foundation
@testable import Raven

enum TestCertificate: String {
    case valid = "objc.io"
    case invalid = "www.google.com"
}

class TestSSLPinningOperation: NetworkOperation {
    
    init(certificate: TestCertificate, service: NetworkService, completion: NetworkOperationCompletion) {
        var sslRequest = Request(endpoint: "", method: .get)
        
        let testBundle = Bundle(for: type(of: self))
        let cert: CertificateResource = (testBundle, certificate.rawValue, "cer")
        sslRequest.serverTrustPolicy = ServerTrustPolicy(certificates: [cert])
        
        super.init(request: sslRequest, service: service)
        self.completion = completion
    }
}
