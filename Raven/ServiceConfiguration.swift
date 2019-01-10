//
//  ServiceConfiguration.swift
//  Raven
//
//  Created by Ramsundar Shandilya on 4/2/18.
//  Copyright © 2018 Ramsundar Shandilya. All rights reserved.
//

import Foundation

struct ServiceConfiguration {
    
    static let appConfig: ServiceConfiguration? = {
        let environment = Environment.current
        
        var config = ServiceConfiguration(name: environment.name, base: environment.baseURL)
        config?.headers = ["Content-Type": "application/json"]
        config?.sessionConfiguration.waitsForConnectivity = true
        config?.sessionConfiguration.timeoutIntervalForResource = 300
        
        return config
    }()
    
    ///Configuration name i.e. Production, Staging, Dev
    let name: String
    
    ///
    let baseURL: URL
    
    ///Include any global headers
    var headers: [String: String] = [:]
    
    var cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
    
    var sessionConfiguration = URLSessionConfiguration.default
    
    var timeout: TimeInterval = 15.0
    
    public init?(name: String? = nil, base urlString: String) {
        guard let url = URL(string: urlString) else { return nil }
        self.baseURL = url
        self.name = name ?? (url.host ?? "")
    }
    
}

enum Environment: Int {
    
    case development = 100
    case staging
    case production
    
    var baseURL: String {
        switch self {
        case .development:
            return "https://api.coinmarketcap.com/v2"
        case .staging:
            return "https://api.coinmarketcap.com/v2"
        case .production:
            return "https://api.coinmarketcap.com/v2/"
        }
    }
    
    static var current: Environment {
        let defaultsKey = "ServiceEnvironment"
        
        let value = UserDefaults.standard.integer(forKey: defaultsKey)
        
        guard let environment = Environment(rawValue: value) else {
            UserDefaults.standard.set(Environment.development.rawValue, forKey: defaultsKey)
            return .development
        }
        return environment
    }
    
    var name: String {
        switch self {
        case .development:
            return "Development"
        case .staging:
            return "Staging"
        case .production:
            return "Production"
        }
    }
}
