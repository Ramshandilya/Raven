//
//  RavenTests.swift
//  RavenTests
//
//  Created by Ramsundar Shandilya on 4/2/18.
//  Copyright © 2018 Ramsundar Shandilya. All rights reserved.
//

import XCTest
@testable import Raven

class RavenTests: XCTestCase {
    
    struct Coin: Codable {
        let id: Int
        let name: String
        let symbol: String
    }
    
    var testNetworkOperation: NetworkOperation?
    var networkController: NetworkController?
    
    let testServiceConfig: ServiceConfiguration? = {
        var serviceConfig = ServiceConfiguration(name: "Test", base: "https://www.mocky.io/v2")
        serviceConfig?.headers = ["Content-Type": "application/json"]
        serviceConfig?.sessionConfiguration.waitsForConnectivity = true
        serviceConfig?.sessionConfiguration.timeoutIntervalForResource = 300
        return serviceConfig
    }()
    
    override func setUp() {
        super.setUp()
        
        networkController = NetworkController()
    }
    
    override func tearDown() {
        super.tearDown()
        
        networkController = nil
        testNetworkOperation = nil
    }
    
    func testResourceOperationSuccess() {
        let exp = expectation(description: "Resource Operation Success Test")
        
        //Given
        //When
        let testResourceOperation = TestResourceOperation(endPoint: .success, service: NetworkService(testServiceConfig!), completion: { (result) in
            defer { exp.fulfill() }
            
            //Then
            switch result {
            case .failure(_):
                XCTFail("Resource Operation Success Test - Failed with error")
            case let .success(data):
                let value = try? JSONDecoder().decode(Coin.self, from: data)
                XCTAssertTrue(value != nil, "Resource Operation Success Test Failed")
            }
        })
        
        networkController?.addOperation(testResourceOperation)
        self.testNetworkOperation = testResourceOperation
        
        waitForExpectations(timeout: 60) { (error) in
            guard error != nil else { return }
            XCTFail("Resource Operation Success Test - Failed with Timeout")
        }
    }
    
    func testClientErrorOperation() {
        let exp = expectation(description: "Client Error Test")
        
        //Given
        //When
        let testResourceOperation = TestResourceOperation(endPoint: .clientError, service: NetworkService(testServiceConfig!), completion: { (result) in
        
            //Then
            switch result {
            case let .failure(error):
                guard let networkError = error as? NetworkError else {
                    XCTFail("Client Error Test - Failed")
                    return
                }
                
                switch networkError {
                case .clientError(_, statusCode: _):
                    exp.fulfill()
                default:
                    XCTFail("Client Error  Test - Failed")
                }
                
            case .success(_):
                XCTFail("Client Error  Test - Failed")
            }
        })
        
        networkController?.addOperation(testResourceOperation)
        self.testNetworkOperation = testResourceOperation
        
        waitForExpectations(timeout: 60) { (error) in
            guard error != nil else { return }
            XCTFail("Resource Operation Success Test - Failed with Timeout")
        }
    }
    
    func testServerErrorOperation() {
        let exp = expectation(description: "Server Error Test")
        
        //Given
        //When
        let testResourceOperation = TestResourceOperation(endPoint: .serverError, service: NetworkService(testServiceConfig!), completion: { (result) in
            
            //Then
            switch result {
            case let .failure(error):
                guard let networkError = error as? NetworkError else {
                    XCTFail("Server Error Test - Failed")
                    return
                }
                
                switch networkError {
                case .serverError(_, statusCode:_):
                    exp.fulfill()
                default:
                    XCTFail("Server Error Test - Failed")
                }
                
            case .success(_):
                XCTFail("Server Error Test - Failed")
            }
        })
        
        networkController?.addOperation(testResourceOperation)
        self.testNetworkOperation = testResourceOperation
        
        waitForExpectations(timeout: 60) { (error) in
            guard error != nil else { return }
            XCTFail("Server Error Test - Failed with Timeout")
        }
    }
    
    func testParsingErrorOperation() {
        let exp = expectation(description: "Parsing Error Test")
        
        //Given
        //When
        let testResourceOperation = TestResourceOperation(endPoint: .parsingError, service: NetworkService(testServiceConfig!), completion: { (result) in
            
            //Then
            switch result {
            case .failure(_):
                XCTFail("Parsing Error Test - Failed with error")
            case let .success(data):
                do {
                    let _ = try JSONDecoder().decode(Coin.self, from: data)
                    XCTFail("Parsing Error Test - Failed with error")
                } catch {
                    exp.fulfill()
                }
            }
        })
        
        networkController?.addOperation(testResourceOperation)
        self.testNetworkOperation = testResourceOperation
        
        waitForExpectations(timeout: 60) { (error) in
            guard error != nil else { return }
            XCTFail("Parsing Error Test - Failed with Timeout")
        }
    }
}
