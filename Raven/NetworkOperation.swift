//
//  NetworkOperation.swift
//  Raven
//
//  Created by Ramsundar Shandilya on 4/4/18.
//  Copyright © 2018 Ramsundar Shandilya. All rights reserved.
//

import Foundation

class NetworkOperation: BaseOperation {
    
    typealias NetworkOperationCompletion = ((Result<Data>) -> Void)?
    
    private let request: Request
    private let service: NetworkService
    
    private var processingTime: TimeInterval = 0
    private var dataLength: Int = 0
    
    public var completion: NetworkOperationCompletion
    
    ///Kilobytes/sec
    public var bandwidth: Double {
        guard processingTime > 0 else {
            return 0
        }
        return (Double(dataLength)/processingTime/1024).rounded()
    }
    
    init(request: Request, service: NetworkService) {
        self.request = request
        self.service = service
        super.init()
    }
    
    override func execute() {
        NetworkLog.debug("\n▶️ Sending Request - \n\(request.debugDescription)")
        
        let startTime = Date()
        service.execute(request: request, sessionDelegate: self) {[weak self] (result) in
            
            switch result {
            case .failure(let error):
                self?.completion?(Result.failure(error))
                
                NetworkLog.debug("⛔️ Error  -  \n\(error)")
                
                if let isFinished = self?.isFinished, !isFinished {
                    self?.finish(errors: [error])
                }
            case .success(let data):
                let endTime = Date()
                self?.processingTime = endTime.timeIntervalSince(startTime)
                NetworkLog.debug("✅ Success - \(endTime.timeIntervalSince(startTime)) seconds")
                
                self?.dataLength = data.count
                self?.completion?(Result.success(data))
                
                if let isFinished = self?.isFinished, !isFinished {
                    self?.finish()
                }
            }
        }
    }
    
    override func cancel() {
        service.cancel()
        super.cancel()
    }
}

extension NetworkOperation: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        guard let trustPolicy = request.serverTrustPolicy else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        trustPolicy.handle(challenge: challenge, completion: completionHandler)
    }
}
