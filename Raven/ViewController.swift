//
//  ViewController.swift
//  Raven
//
//  Created by Ramsundar Shandilya on 4/2/18.
//  Copyright © 2018 Ramsundar Shandilya. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let service = NetworkService(ServiceConfiguration.appConfig!)
        
        let networkController = NetworkController()
        
        let coinListOperation = CoinListOperation(service: service) { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let pagedCurrencies):
                break
//                print(pagedCurrencies.currencies)
            }
        }
        
        let coinListOperation2 = CoinListOperation(service: service) { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let pagedCurrencies):
                break
//                print(pagedCurrencies.currencies)
            }
        }
        
        networkController.addOperation(coinListOperation)
        networkController.addOperation(coinListOperation2)
    }
}

extension ViewController: OperationObserver {
    func operationDidStart(_ operation: BaseOperation) {
        
    }
    
    func operationDidFinish(_ operation: BaseOperation, errors: [Error]) {
        
    }
}


struct PagedCurrencies: Codable {
    let currencies: [Currency]
    
    struct Currency: Codable {
        let id: Int
        let name: String
        let symbol: String
    }
    
    enum CodingKeys: String, CodingKey {
        case currencies = "data"
    }
}

class CoinListOperation: NetworkOperation {
    
    typealias CoinListOperationCompletion = ((Result<PagedCurrencies>) -> Void)?
    
    init(service: NetworkService, completion: CoinListOperationCompletion) {
        let coinRequest = Request(endpoint: "/listings", method: .get)
        
        super.init(request: coinRequest, service: service)
        self.completion = {[weak self] result in
            switch result {
            case let .failure(error):
                completion?(Result.failure(error))
            case .success(let data):
                
                do  {
                    let value = try JSONDecoder().decode(PagedCurrencies.self, from: data)
                    completion?(Result.success(value))
                    self?.finish()
                } catch {
                    completion?(Result.failure(NetworkError.failedToParseResponse))
                    self?.finish(errors: [error])
                }
            }
        }
    }
}


