//
//  ServerTrustPolicy.swift
//  Raven
//
//  Created by Ramsundar Shandilya on 7/24/18.
//  Copyright © 2018 Ramsundar Shandilya. All rights reserved.
//

import Foundation

typealias CertificateResource = (bundle: Bundle, filename: String, `extension`: String)

struct ServerTrustPolicy {
    var certificates: [CertificateResource]
    
    func handle(challenge: URLAuthenticationChallenge, completion: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        let localPublicKeys: [SecKey] = certificates.compactMap {
            guard let url = $0.bundle.url(forResource: $0.filename, withExtension: $0.extension),
                let data = try? Data(contentsOf: url),
                let localCertificate = SecCertificateCreateWithData(nil, data as CFData),
                let publicKey = publicKey(for: localCertificate) else {
                    return nil
            }
            return publicKey
        }
        
        guard let trust = challenge.protectionSpace.serverTrust,
            SecTrustGetCertificateCount(trust) > 0,
            let serverCertificate = SecTrustGetCertificateAtIndex(trust, 0) else {
                completion(.cancelAuthenticationChallenge, nil)
                return
        }
        
        guard let serverPublicKey = publicKey(for: serverCertificate),
            localPublicKeys.contains(serverPublicKey) else {
                completion(.cancelAuthenticationChallenge, nil)
                return
        }
        
        completion(.useCredential, URLCredential(trust: trust))
    }
}

private extension ServerTrustPolicy {
    
    func publicKey(for certificate: SecCertificate) -> SecKey? {
        var publicKey: SecKey?
        
        let policy = SecPolicyCreateBasicX509()
        var trust: SecTrust?
        let trustCreationStatus = SecTrustCreateWithCertificates(certificate, policy, &trust)
        
        if let trust = trust, trustCreationStatus == errSecSuccess {
            publicKey = SecTrustCopyPublicKey(trust)
        }
        
        return publicKey
    }
}
