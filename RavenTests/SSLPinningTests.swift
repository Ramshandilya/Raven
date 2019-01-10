//
//  SSLPinningTests.swift
//  RavenTests
//
//  Created by Ramsundar Shandilya on 8/1/18.
//  Copyright © 2018 Ramsundar Shandilya. All rights reserved.
//

import XCTest
@testable import Raven

class SSLPinningTests: XCTestCase {
    
    var testNetworkOperation: NetworkOperation?
    var networkController: NetworkController?
    
    override func setUp() {
        super.setUp()
        
        networkController = NetworkController()
    }
    
    override func tearDown() {
        super.tearDown()
        
        networkController = nil
        testNetworkOperation = nil
    }
    
    func testSSLPinningSuccess() {
        //Given
        var serviceConfig = ServiceConfiguration(name: "SSL Test", base: "https://www.objc.io/")
        serviceConfig?.headers = ["Content-Type": "application/json"]
        serviceConfig?.sessionConfiguration.waitsForConnectivity = true
        serviceConfig?.sessionConfiguration.timeoutIntervalForResource = 300
        
        let exp = expectation(description: "SSL Pinning Success Test")
        
        //When
        let testSSLOperation = TestSSLPinningOperation(certificate: .valid, service: NetworkService(serviceConfig!), completion: { (result) in
            
            //Then
            switch result {
            case .failure(_):
                XCTFail("SSL Pinning Success Test - Failed with error")
            case .success(_):
                exp.fulfill()
            }
        })
        
        networkController?.addOperation(testSSLOperation)
        self.testNetworkOperation = testSSLOperation
        
        waitForExpectations(timeout: 60) { (error) in
            guard error != nil else { return }
            XCTFail("SSL Pinning Success - Failed with Timeout")
        }
    }
    
    func testSSLPinningFailure() {
        //Given
        var serviceConfig = ServiceConfiguration(name: "Test", base: "https://www.objc.io/")
        serviceConfig?.headers = ["Content-Type": "application/json"]
        serviceConfig?.sessionConfiguration.waitsForConnectivity = true
        serviceConfig?.sessionConfiguration.timeoutIntervalForResource = 300
        
        let exp = expectation(description: "SSL Pinning Success Test")
        
        //When
        let testSSLOperation = TestSSLPinningOperation(certificate: .invalid, service: NetworkService(serviceConfig!), completion: { (result) in
           
            //Then
            switch result {
            case .failure(_):
                exp.fulfill()
            case .success(_):
                XCTFail("SSL Pinning Success Test - Failed with error")
            }
        })
        
        networkController?.addOperation(testSSLOperation)
        self.testNetworkOperation = testSSLOperation
        
        waitForExpectations(timeout: 60) { (error) in
            guard error != nil else { return }
            XCTFail("SSL Pinning Success - Failed with Timeout")
        }
    }
    
}
