//
//  Session.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 02/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import OtsimoApiGrpc

public class Session {
    internal let config : ClientConfig
    internal var accessToken: String = ""
    internal var refreshToken: String = ""
    internal var tokenType: String = ""
    public var emailVerified: Bool = false
    public var expiresAt: Int64 = 0
    public var issuedAt: Int64 = 0
    public var issuer: String = ""
    public var clientID: String = ""
    public var displayName: String = ""
    public var profileID: String = ""
    public var email: String = ""
    
    internal var profile: OTSProfile? = nil
    
    public var isAuthenticated: Bool {
        get {
            return accessToken != ""
        }
    }
    
    public var isTokenExpired: Bool {
        get {
            let exp = NSDate(timeIntervalSince1970: Double(expiresAt))
            if exp.compare(NSDate()) == NSComparisonResult.OrderedDescending
            {
                return false
            }
            return true
        }
    }
    
    internal init(config: ClientConfig) {
        self.config = config
    }
    
    public func logout() {
        accessToken = ""
        profileID = ""
    }
    
    internal func save() {
        // todo save session to ...
    }
    
    internal func loadToken() -> LoadResult {
        let res = loadJwt(accessToken)
        switch (res) {
        case LoadResult.Success(_, let payload, _, _):
            let presult = loadPayload(payload)
            switch (presult) {
            case PayloadLoadResult.Success:
                return res
            case PayloadLoadResult.Failure(let it):
                return LoadResult.Failure(it)
            }
        default:
            return res
        }
    }
    
    internal func loadPayload(payload: Payload) -> PayloadLoadResult {
        if let sub = payload["sub"] as? String {
            profileID = sub
        } else {
            return PayloadLoadResult.Failure(InvalidToken.MissingSub)
        }
        
        if let e = payload["email"] as? String {
            email = e
        } else {
            return PayloadLoadResult.Failure(InvalidToken.MissingEmail)
        }
        
        if let e = payload["email_verified"] as? Bool {
            emailVerified = e
        } else {
            emailVerified = false
        }
        
        let it = validateIssuer(payload, issuer: self.config.issuer)
        
        if let i = it {
            return PayloadLoadResult.Failure(i)
        }
        
        if let i = payload["iss"] as? String {
            // todo look validate issuer
            issuer = i
        } else {
            return PayloadLoadResult.Failure(InvalidToken.InvalidIssuer)
        }
        
        if let n = payload["name"] as? String {
            displayName = n
        } else {
            displayName = ""
        }
        
        return .Success
    }
}