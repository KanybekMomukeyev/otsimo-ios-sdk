//
//  Errors.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 04/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation

public protocol OtsimoErrorProtocol {
    func silentError(_ src: String, err: OtsimoError)
}

public enum TokenResult {
    case success
    case error(error: OtsimoError)
}

enum LoadResult {
    case success(header: Payload, payload: Payload, signature: Data, signatureInput: String)
    case failure(InvalidToken)
}

enum PayloadLoadResult {
    case success
    case failure(InvalidToken)
}

public enum InvalidToken: CustomStringConvertible, Error {
    // / Decoding the JWT itself failed
    case decodeError(String)

    // / The JWT uses an unsupported algorithm
    case invalidAlgorithm

    // / The issued claim has expired
    case expiredSignature

    // / The issued claim is for the future
    case immatureSignature

    // / The claim is for the future
    case invalidIssuedAt

    // / The audience of the claim doesn't match
    case invalidAudience

    // / The issuer claim failed to verify
    case invalidIssuer

    // The issuer claim failed to verify
    case missingSub

    // The issuer claim failed to verify
    case missingEmail

    case missingExp

    // / Returns a readable description of the error
    public var description: String {
        switch self {
        case .decodeError(let error):
            return "Decode Error: \(error)"
        case .invalidIssuer:
            return "Invalid Issuer"
        case .expiredSignature:
            return "Expired Signature"
        case .immatureSignature:
            return "The token is not yet valid (not before claim)"
        case .invalidIssuedAt:
            return "Issued at claim (iat) is in the future"
        case .invalidAudience:
            return "Invalid Audience"
        case .invalidAlgorithm:
            return "Unsupported algorithm or incorrect key"
        case .missingSub:
            return "Sub is missing"
        case .missingEmail:
            return "Email is missing"
        case .missingExp:
            return "Expire time is missing"
        }
    }
}

public enum OtsimoError {
    case none
    case notInitialized
    case expiredValue
    case general(message: String)
    case notLoggedIn(message: String)
    case serviceError(message: String)
    case networkError(message: String)
    case invalidResponse(message: String)
    case invalidTokenError(error: InvalidToken)
}
