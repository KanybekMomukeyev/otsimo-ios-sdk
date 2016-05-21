//
//  Session.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 02/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import OtsimoApiGrpc
import Locksmith

struct OtsimoAccountOLD: ReadableSecureStorable, CreateableSecureStorable,
                         DeleteableSecureStorable, GenericPasswordSecureStorable {
    let email: String
    let jwt: String
    let refresh: String
    let tokentype: String
    let service = "Otsimo"
    var account: String { return email }

    var data: [String: AnyObject] {
        return ["jwt": jwt, "refresh": refresh, "tokentype": tokentype]
    }
}
struct OtsimoAccount: ReadableSecureStorable, CreateableSecureStorable,
                       DeleteableSecureStorable, GenericPasswordSecureStorable {
    let email: String
    let jwt: String
    let refresh: String
    let tokentype: String
    let service = "Otsimo"
    var account: String { return email }
    
    var data: [String: AnyObject] {
        return ["jwt": jwt, "refresh": refresh, "tokentype": tokentype]
    }
}

public class Session {
    internal let config : ClientConfig
    internal var accessToken: String = ""
    internal var refreshToken: String = ""
    internal var tokenType: String = ""
    public var emailVerified: Bool = false
    public var expiresAt: Int = 0
    public var issuedAt: Int64 = 0
    public var issuer: String = ""
    public var clientID: String = ""
    public var displayName: String = ""
    public var profileID: String = ""
    public var email: String = ""

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
        Otsimo.sharedInstance.cache.clearSession()
        let account = OtsimoAccount(email: email, jwt: accessToken, refresh: refreshToken, tokentype: tokenType)
        do {
            try account.deleteFromSecureStore()
        } catch {
            Log.error("failed to clear account information: \(error)")
        }
    }
    
    internal func save() {
        if isAuthenticated {
            let sc = SessionCache()
            sc.profileId = self.profileID
            sc.email = self.email

            let account = OtsimoAccount(email: email, jwt: accessToken, refresh: refreshToken, tokentype: tokenType)
            do {
                try account.createInSecureStore()
                Otsimo.sharedInstance.cache.cacheSession(sc)
                Log.info("session is saved")
            } catch {
                switch (error) {
                case LocksmithError.Duplicate:
                    do {
                        try account.deleteFromSecureStore()
                        try account.createInSecureStore()
                        Otsimo.sharedInstance.cache.cacheSession(sc)
                        Log.info("session is saved")
                    } catch {
                        Log.error("failed to save account information: \(error)")
                    }
                default:
                    Log.error("failed to save account information: \(error)")
                }
            }
        } else {
            Log.error("session is not saved because user is not authenticated")
        }
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

        if let e = payload["exp"] as? Int {
            expiresAt = e
        } else {
            return PayloadLoadResult.Failure(InvalidToken.MissingExp)
        }

        return .Success
    }

    func getAuthorizationHeader(handler: (String, OtsimoError) -> Void) {
        if isAuthenticated {
            if isTokenExpired {
                dispatch_barrier_async(sessionQueue) {
                    if self.isTokenExpired {
                        Log.debug("access token is expired")
                        let refreshGroup = dispatch_group_create() // Create Group
                        dispatch_group_enter(refreshGroup) // Enter Group
                        self.refreshCurrentToken { err in
                            onMainThread {
                                Log.debug("access token got \(err)")
                                switch (err) {
                                case .None:
                                    handler(self.accessToken, OtsimoError.None)
                                default:
                                    handler(self.accessToken, err)
                                }
                            }
                            dispatch_group_leave(refreshGroup) // Leave Group
                        }
                        dispatch_group_wait(refreshGroup, DISPATCH_TIME_FOREVER) // Wait completing the group
                    } else {
                        Log.debug("new token is got, sending it")
                        onMainThread { handler(self.accessToken, OtsimoError.None) }
                    }
                }
            } else {
                handler(accessToken, OtsimoError.None)
            }
        } else {
            handler("", OtsimoError.NotLoggedIn(message: "not logged in"))
        }
    }
    
    internal static func loadLastSession(config: ClientConfig, handler: (Session?) -> Void) {
        
        
        if let sc = Otsimo.sharedInstance.cache.fetchSession() {
            let account = OtsimoAccount(email: sc.email, jwt: "", refresh: "", tokentype: "")
            if let result = account.readFromSecureStore() {
                let session = Session(config: config)
                
                session.profileID = sc.profileId
                session.email = sc.email
                session.accessToken = result.data?["jwt"] as! String
                session.refreshToken = result.data?["refresh"] as! String
                session.tokenType = result.data?["tokentype"] as! String
                
                if session.refreshToken == "" {
                    Log.error("there is no 'refresh' data at account information")
                    handler(nil)
                    return
                }
                if session.tokenType == "" {
                    Log.error("there is no 'tokentype' data at account information")
                    handler(nil)
                    return
                }
                let res = session.loadToken()
                switch (res) {
                case .Success:
                    Log.debug("old session loaded successfully")
                    handler(session)
                case .Failure(let it):
                    Log.error("failed to load jwt token, error:\(it)")
                    handler(nil)
                }
            } else {
                Log.error("there is no account information on keychain")
                handler(nil)
            }
        } else {
            Log.info("could not find any previous session, need to login")
            handler(nil)
        }
    }

    private func refreshCurrentToken(handler: (error: OtsimoError) -> Void) {
        let grant_type = "refresh_token"
        let urlPath: String = "\(config.accountsServiceUrl)/refresh"
        let postString = "grant_type=\(grant_type)&refresh_token=\(refreshToken)&client_id=\(config.clientID)"

        let request = NSMutableURLRequest(URL: NSURL(string: urlPath)!)
        request.HTTPMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        request.timeoutInterval = 20
        request.cachePolicy = .ReloadIgnoringLocalAndRemoteCacheData

        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else { // check for fundamental networking error
                handler(error: .NetworkError(message: "\(error)"))
                return
            }
            var isOK = true
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 { // check for http errors
                isOK = false
            }

            do {
                let JSON = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))
                guard let JSONDictionary : NSDictionary = JSON as? NSDictionary else {
                    handler(error: .InvalidResponse(message: "invalid response:not a dictionary"))
                    return
                }
                if isOK && JSONDictionary["error"] == nil {
                    let accessToken: String? = JSONDictionary["access_token"] as? String
                    let refreshToken: String? = JSONDictionary["refresh_token"] as? String
                    let tokenType: String? = JSONDictionary["token_type"] as? String

                    if let at = accessToken {
                        self.accessToken = at
                    } else {
                        handler(error: .InvalidResponse(message: "invalid response: access_token is missing"))
                        return
                    }

                    if let rt = refreshToken {
                        self.refreshToken = rt
                    } else {
                        handler(error: .InvalidResponse(message: "invalid response: refresh_token is missing"))
                        return
                    }

                    if let tt = tokenType {
                        self.tokenType = tt
                    } else {
                        self.tokenType = "bearer"
                    }
                    let lr = self.loadToken()
                    switch (lr) {
                    case .Success(_, _, _, _):
                        onMainThread { self.save() }
                        handler(error: .None)
                    case .Failure(let it):
                        handler(error: OtsimoError.InvalidTokenError(error: it))
                    }
                } else {
                    let e = JSONDictionary["error"]
                    if e != nil {
                        handler(error: .InvalidResponse(message: "request failed: error= \(e)"))
                    } else {
                        handler(error: .InvalidResponse(message: "request failed: \(data)"))
                    }
                }
            }
            catch let JSONError as NSError {
                handler(error: .InvalidResponse(message: "invalid response: \(JSONError)"))
            }
        }
        task.resume()
    }
    
    internal static func migrageToSharedKeyChain(){
        
    }
    
}