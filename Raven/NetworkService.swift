//
//  NetworkService.swift
//  Raven
//
//  Created by Ramsundar Shandilya on 4/2/18.
//  Copyright © 2018 Ramsundar Shandilya. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    
    case head = "HEAD"
    case patch = "PATCH"
    case trace = "TRACE"
    case connect = "CONNECT"
    case options = "OPTIONS"
}

enum NetworkError: Error {
    case noData
    case dataIsNotEncodable(_: Any)
    case networkingError(Error?)
    case clientError(Error?, statusCode: Int)
    case serverError(Error?, statusCode: Int)
    case failedToParseResponse
    case unknown(Error?)
}

final class NetworkService {
    
    var configuration: ServiceConfiguration
    
    var session: URLSession?
    
    var task: URLSessionTask?
    
    private var successCodes: Range<Int> = 200..<299
    private var clientErrorCodes: Range<Int> = 400..<499
    private var serverErrorCodes: Range<Int> = 500..<599
    
    required init(_ configuration: ServiceConfiguration) {
        self.configuration = configuration
    }
    
    func execute(request: Request, sessionDelegate: URLSessionDelegate?, completion: ((Result<Data>) -> Void)?) {
        
        session = URLSession(configuration: configuration.sessionConfiguration, delegate: sessionDelegate, delegateQueue: nil)
        
        let url = configuration.baseURL.appendingPathComponent(request.endpoint)
        let urlRequest = URLRequest(url: url, cachePolicy: request.cachePolicy ?? configuration.cachePolicy, timeoutInterval: request.timeout ?? configuration.timeout)
        
        task = session?.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            
            if let error = error {
                completion?(Result.failure(NetworkError.networkingError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion?(Result.failure(NetworkError.networkingError(error)))
                return
            }
            
            switch httpResponse.statusCode {
            case self.successCodes:
                guard let data = data else {
                    completion?(Result.failure(NetworkError.noData))
                    return
                }
                completion?(Result.success(data))
                return
            case self.clientErrorCodes:
                completion?(Result.failure(NetworkError.clientError(error, statusCode: httpResponse.statusCode)))
                return
            case self.serverErrorCodes:
                completion?(Result.failure(NetworkError.serverError(error, statusCode: httpResponse.statusCode)))
                return
            default:
                completion?(Result.failure(NetworkError.unknown(error)))
                return
            }
        })
        task?.resume()
    }
    
    func cancel() {
        session?.invalidateAndCancel()
        task?.cancel()
    }
}
