//
//  Util.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 04/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation

public typealias Payload = [String: AnyObject]

func loadJwt(_ jwt: String) -> LoadResult {
    let segments = jwt.components(separatedBy: ".")
    if segments.count != 3 {
        return LoadResult.failure(.decodeError("Not enough segments"))
    }

    let headerSegment = segments[0]
    let payloadSegment = segments[1]
    let signatureSegment = segments[2]
    let signatureInput = "\(headerSegment).\(payloadSegment)"

    let headerData = base64decode(headerSegment)
    if headerData == nil {
        return LoadResult.failure(.decodeError("Header is not correctly encoded as base64"))
    }

    let header = (try? JSONSerialization.jsonObject(with: headerData!, options: JSONSerialization.ReadingOptions(rawValue: 0))) as? Payload
    if header == nil {
        return LoadResult.failure(.decodeError("Invalid header"))
    }

    let payloadData = base64decode(payloadSegment)
    if payloadData == nil {
        return LoadResult.failure(.decodeError("Payload is not correctly encoded as base64"))
    }

    let payload = (try? JSONSerialization.jsonObject(with: payloadData!, options: JSONSerialization.ReadingOptions(rawValue: 0))) as? Payload
    if payload == nil {
        return LoadResult.failure(.decodeError("Invalid payload"))
    }

    let signature = base64decode(signatureSegment)
    if signature == nil {
        return LoadResult.failure(.decodeError("Signature is not correctly encoded as base64"))
    }

    return .success(header: header!, payload: payload!, signature: signature!, signatureInput: signatureInput)
}

func base64decode(_ input: String) -> Data? {
    let rem = input.characters.count % 4

    var ending = ""
    if rem > 0 {
        let amount = 4 - rem
        ending = String(repeating: "=", count: amount)
    }

    let base64 = input.replacingOccurrences(of: "-", with: "+", options: NSString.CompareOptions(rawValue: 0), range: nil)
        .replacingOccurrences(of: "_", with: "/", options: NSString.CompareOptions(rawValue: 0), range: nil) + ending

    return Data(base64Encoded: base64, options: NSData.Base64DecodingOptions(rawValue: 0))
}

func validateClaims(_ payload: Payload, issuer: String?) -> InvalidToken? {
    return validateIssuer(payload, issuer: issuer) ??
    validateDate(payload, key: "exp", comparison: .orderedAscending, failure: .expiredSignature, decodeError: "Expiration time claim (exp) must be an integer") ??
    validateDate(payload, key: "iat", comparison: .orderedDescending, failure: .invalidIssuedAt, decodeError: "Issued at claim (iat) must be an integer")
}

func validateAudience(_ payload: Payload, audience: String?) -> InvalidToken? {
    if let audience = audience {
        if let aud = payload["aud"] as? [String] {
            if !aud.contains(audience) {
                return .invalidAudience
            }
        } else if let aud = payload["aud"] as? String {
            if aud != audience {
                return .invalidAudience
            }
        } else {
            return .decodeError("Invalid audience claim, must be a string or an array of strings")
        }
    }

    return nil
}

func validateIssuer(_ payload: Payload, issuer: String?) -> InvalidToken? {
    if let issuer = issuer {
        if let iss = payload["iss"] as? String {
            if iss != issuer {
                return .invalidIssuer
            }
        } else {
            return .invalidIssuer
        }
    }

    return nil
}

func validateDate(_ payload: Payload, key: String, comparison: ComparisonResult, failure: InvalidToken, decodeError: String) -> InvalidToken? {
    if let timestamp = payload[key] as? TimeInterval ?? payload[key]?.doubleValue as TimeInterval? {
        let date = Date(timeIntervalSince1970: timestamp)
        if date.compare(Date()) == comparison {
            return failure
        }
    } else if payload[key] != nil {
        return .decodeError(decodeError)
    }

    return nil
}
