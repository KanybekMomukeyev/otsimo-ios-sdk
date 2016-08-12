//
//  Util.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 04/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation

public typealias Payload = [String: AnyObject]

func loadJwt(jwt: String) -> LoadResult {
    let segments = jwt.componentsSeparatedByString(".")
    if segments.count != 3 {
        return LoadResult.Failure(.DecodeError("Not enough segments"))
    }

    let headerSegment = segments[0]
    let payloadSegment = segments[1]
    let signatureSegment = segments[2]
    let signatureInput = "\(headerSegment).\(payloadSegment)"

    let headerData = base64decode(headerSegment)
    if headerData == nil {
        return LoadResult.Failure(.DecodeError("Header is not correctly encoded as base64"))
    }

    let header = (try? NSJSONSerialization.JSONObjectWithData(headerData!, options: NSJSONReadingOptions(rawValue: 0))) as? Payload
    if header == nil {
        return LoadResult.Failure(.DecodeError("Invalid header"))
    }

    let payloadData = base64decode(payloadSegment)
    if payloadData == nil {
        return LoadResult.Failure(.DecodeError("Payload is not correctly encoded as base64"))
    }

    let payload = (try? NSJSONSerialization.JSONObjectWithData(payloadData!, options: NSJSONReadingOptions(rawValue: 0))) as? Payload
    if payload == nil {
        return LoadResult.Failure(.DecodeError("Invalid payload"))
    }

    let signature = base64decode(signatureSegment)
    if signature == nil {
        return LoadResult.Failure(.DecodeError("Signature is not correctly encoded as base64"))
    }

    return .Success(header: header!, payload: payload!, signature: signature!, signatureInput: signatureInput)
}

func base64decode(input: String) -> NSData? {
    let rem = input.characters.count % 4

    var ending = ""
    if rem > 0 {
        let amount = 4 - rem
        ending = String(count: amount, repeatedValue: Character("="))
    }

    let base64 = input.stringByReplacingOccurrencesOfString("-", withString: "+", options: NSStringCompareOptions(rawValue: 0), range: nil)
        .stringByReplacingOccurrencesOfString("_", withString: "/", options: NSStringCompareOptions(rawValue: 0), range: nil) + ending

    return NSData(base64EncodedString: base64, options: NSDataBase64DecodingOptions(rawValue: 0))
}

func validateClaims(payload: Payload, issuer: String?) -> InvalidToken? {
    return validateIssuer(payload, issuer: issuer) ??
    validateDate(payload, key: "exp", comparison: .OrderedAscending, failure: .ExpiredSignature, decodeError: "Expiration time claim (exp) must be an integer") ??
    validateDate(payload, key: "iat", comparison: .OrderedDescending, failure: .InvalidIssuedAt, decodeError: "Issued at claim (iat) must be an integer")
}

func validateAudience(payload: Payload, audience: String?) -> InvalidToken? {
    if let audience = audience {
        if let aud = payload["aud"] as? [String] {
            if !aud.contains(audience) {
                return .InvalidAudience
            }
        } else if let aud = payload["aud"] as? String {
            if aud != audience {
                return .InvalidAudience
            }
        } else {
            return .DecodeError("Invalid audience claim, must be a string or an array of strings")
        }
    }

    return nil
}

func validateIssuer(payload: Payload, issuer: String?) -> InvalidToken? {
    if let issuer = issuer {
        if let iss = payload["iss"] as? String {
            if iss != issuer {
                return .InvalidIssuer
            }
        } else {
            return .InvalidIssuer
        }
    }

    return nil
}

func validateDate(payload: Payload, key: String, comparison: NSComparisonResult, failure: InvalidToken, decodeError: String) -> InvalidToken? {
    if let timestamp = payload[key] as? NSTimeInterval ?? payload[key]?.doubleValue as NSTimeInterval? {
        let date = NSDate(timeIntervalSince1970: timestamp)
        if date.compare(NSDate()) == comparison {
            return failure
        }
    } else if payload[key] != nil {
        return .DecodeError(decodeError)
    }

    return nil
}
