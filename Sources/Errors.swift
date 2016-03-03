//
//  Errors.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 04/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation

public enum TokenResult {
    case Success
    case Error(error: OtsimoError)
}

enum LoadResult {
    case Success(header: Payload, payload: Payload, signature: NSData, signatureInput: String)
    case Failure(InvalidToken)
}

enum PayloadLoadResult {
    case Success
    case Failure(InvalidToken)
}

public enum InvalidToken : CustomStringConvertible, ErrorType {
    // / Decoding the JWT itself failed
    case DecodeError(String)

    // / The JWT uses an unsupported algorithm
    case InvalidAlgorithm

    // / The issued claim has expired
    case ExpiredSignature

    // / The issued claim is for the future
    case ImmatureSignature

    // / The claim is for the future
    case InvalidIssuedAt

    // / The audience of the claim doesn't match
    case InvalidAudience

    // / The issuer claim failed to verify
    case InvalidIssuer

    // The issuer claim failed to verify
    case MissingSub

    // The issuer claim failed to verify
    case MissingEmail

    case MissingExp

    // / Returns a readable description of the error
    public var description: String {
        switch self {
        case .DecodeError(let error):
            return "Decode Error: \(error)"
        case .InvalidIssuer:
            return "Invalid Issuer"
        case .ExpiredSignature:
            return "Expired Signature"
        case .ImmatureSignature:
            return "The token is not yet valid (not before claim)"
        case .InvalidIssuedAt:
            return "Issued at claim (iat) is in the future"
        case InvalidAudience:
            return "Invalid Audience"
        case InvalidAlgorithm:
            return "Unsupported algorithm or incorrect key"
        case MissingSub:
            return "Sub is missing"
        case MissingEmail:
            return "Email is missing"
        case .MissingExp:
            return "Expire time is missing"
        }
    }
}

public enum OtsimoError {
    case None
    case NotInitialized
    case General(message: String)
    case NotLoggedIn(message: String)
    case ServiceError(message: String)
    case NetworkError(message: String)
    case InvalidResponse(message: String)
    case InvalidTokenError(error: InvalidToken)
}
