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

let userIDKey = "OtsimoSDK-Session-UserID"
let emailKey = "OtsimoSDK-Session-Email"

struct OtsimoAccount: ReadableSecureStorable, CreateableSecureStorable,
DeleteableSecureStorable, GenericPasswordSecureStorable {
    let email: String
    let jwt: String
    let refresh: String
    let tokentype: String
    let service = "Otsimo"
    let sharedKeyChain: String?
    var account: String { return email }
    var accessGroup: String? { return sharedKeyChain }

    var data: [String: AnyObject] {
        return ["jwt": jwt as AnyObject, "refresh": refresh as AnyObject, "tokentype": tokentype as AnyObject]
    }
}

open class Session {
    internal let config: ClientConfig
    internal var accessToken: String = ""
    internal var refreshToken: String = ""
    internal var tokenType: String = ""
    open var emailVerified: Bool = false
    open var expiresAt: Int = 0
    open var issuedAt: Int64 = 0
    open var issuer: String = ""
    open var clientID: String = ""
    open var displayName: String = ""
    open var profileID: String = ""
    open var email: String = ""

    open var isAuthenticated: Bool {
        get {
            return accessToken != ""
        }
    }
    open var isTokenExpired: Bool {
        get {
            let exp = Date(timeIntervalSince1970: Double(expiresAt))
            if exp.compare(Date()) == ComparisonResult.orderedDescending
            {
                return false
            }
            return true
        }
    }

    internal init(config: ClientConfig) {
        self.config = config
    }

    open func logout() {
        accessToken = ""
        profileID = ""
        Otsimo.sharedInstance.cache.clearSession()
        let account = OtsimoAccount(email: email,
            jwt: accessToken,
            refresh: refreshToken,
            tokentype: tokenType,
            sharedKeyChain: config.sharedKeyChain)
        do {
            try account.deleteFromSecureStore()
        } catch {
            Log.error("failed to clear account information: \(error)")
        }
        let defaults = Session.userDefaults(config.appGroup)
        defaults.removeObject(forKey: emailKey)
        defaults.removeObject(forKey: userIDKey)
        defaults.synchronize()
    }

    internal func save() {
        if isAuthenticated {
            let defaults = Session.userDefaults(config.appGroup)

            defaults.setValue(email, forKey: emailKey)
            defaults.setValue(profileID, forKey: userIDKey)
            defaults.synchronize()
            let account = OtsimoAccount(email: email,
                jwt: accessToken,
                refresh: refreshToken,
                tokentype: tokenType,
                sharedKeyChain: config.sharedKeyChain)
            do {
                try account.updateInSecureStore()
                Log.info("session is saved")
            } catch {
                Log.error("failed to save account information: \(error)")
            }
        } else {
            Log.error("session is not saved because user is not authenticated")
        }
    }

    internal func loadToken() -> LoadResult {
        let res = loadJwt(accessToken)
        switch (res) {
        case LoadResult.success(_, let payload, _, _):
            let presult = loadPayload(payload)
            switch (presult) {
            case PayloadLoadResult.success:
                return res
            case PayloadLoadResult.failure(let it):
                return LoadResult.failure(it)
            }
        default:
            return res
        }
    }

    internal func loadPayload(_ payload: Payload) -> PayloadLoadResult {

        if let sub = payload["sub"] as? String {
            profileID = sub
        } else {
            return PayloadLoadResult.failure(InvalidToken.missingSub)
        }

        if let e = payload["email"] as? String {
            email = e
        } else {
            return PayloadLoadResult.failure(InvalidToken.missingEmail)
        }

        if let e = payload["email_verified"] as? Bool {
            emailVerified = e
        } else {
            emailVerified = false
        }

        let it = validateIssuer(payload, issuer: self.config.issuer)

        if let i = it {
            return PayloadLoadResult.failure(i)
        }

        if let i = payload["iss"] as? String {
            // todo look validate issuer
            issuer = i
        } else {
            return PayloadLoadResult.failure(InvalidToken.invalidIssuer)
        }

        if let n = payload["name"] as? String {
            displayName = n
        } else {
            displayName = ""
        }

        if let n = payload["aud"] as? String {
            clientID = n
        } else {
            clientID = ""
        }

        if let e = payload["exp"] as? Int {
            expiresAt = e
        } else {
            return PayloadLoadResult.failure(InvalidToken.missingExp)
        }

        return .success
    }

    func getAuthorizationHeader(_ handler: @escaping (String, OtsimoError) -> Void) {
        if isAuthenticated {
            if isTokenExpired {
                sessionQueue.async(flags: .barrier, execute: {
                    if self.isTokenExpired {
                        Log.debug("access token is expired")
                        let refreshGroup = DispatchGroup() // Create Group
                        refreshGroup.enter() // Enter Group
                        self.refreshCurrentToken { err in
                            onMainThread {
                                Log.debug("access token got \(err)")
                                switch (err) {
                                case .none:
                                    handler(self.accessToken, OtsimoError.none)
                                default:
                                    handler(self.accessToken, err)
                                }
                            }
                            refreshGroup.leave() // Leave Group
                        }
                        refreshGroup.wait(timeout: DispatchTime.distantFuture) // Wait completing the group
                    } else {
                        Log.debug("new token is before got, sending it")
                        onMainThread { handler(self.accessToken, OtsimoError.none) }
                    }
                }) 
            } else {
                handler(accessToken, OtsimoError.none)
            }
        } else {
            handler("", OtsimoError.notLoggedIn(message: "not logged in"))
        }
    }

    internal static func loadLastSession(_ config: ClientConfig, handler: (Session?) -> Void) {
        let defaults = Session.userDefaults(config.appGroup)
        guard let user = defaults.string(forKey: userIDKey) else {
            Log.error("could not find any previous session userid, need to login")
            handler(nil)
            return
        }
        guard let email = defaults.string(forKey: emailKey) else {
            Log.error("could not find any previous session email, need to login")
            handler(nil)
            return
        }
        let account = OtsimoAccount(email: email, jwt: "", refresh: "", tokentype: "", sharedKeyChain: config.sharedKeyChain)
        if let result = account.readFromSecureStore() {
            let session = Session(config: config)

            session.profileID = user
            session.email = email
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
            case .success:
                Log.debug("previous session loaded successfully")
                handler(session)
            case .failure(let it):
                Log.error("failed to load jwt token, error:\(it)")
                handler(nil)
            }
        } else {
            Log.error("there is no account information on keychain")
            handler(nil)
        }
    }

    fileprivate func refreshCurrentToken(_ handler: @escaping (_ error: OtsimoError) -> Void) {
        let grant_type = "refresh_token"
        let urlPath: String = "\(config.accountsServiceUrl)/refresh"
        let postString = "grant_type=\(grant_type)&refresh_token=\(refreshToken)&client_id=\(clientID)"

        let request = NSMutableURLRequest(url: URL(string: urlPath)!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = postString.data(using: String.Encoding.utf8)
        request.timeoutInterval = 20
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil && data != nil else { // check for fundamental networking error
                handler(error: .networkError(message: "\(error)"))
                return
            }
            var isOK = true
            if let httpStatus = response as? HTTPURLResponse , httpStatus.statusCode != 200 { // check for http errors
                isOK = false
            }

            do {
                let JSON = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0))
                guard let JSONDictionary: NSDictionary = JSON as? NSDictionary else {
                    handler(error: .invalidResponse(message: "invalid response:not a dictionary"))
                    return
                }
                if isOK && JSONDictionary["error"] == nil {
                    let accessToken: String? = JSONDictionary["access_token"] as? String
                    let refreshToken: String? = JSONDictionary["refresh_token"] as? String
                    let tokenType: String? = JSONDictionary["token_type"] as? String

                    if let at = accessToken {
                        self.accessToken = at
                    } else {
                        handler(error: .invalidResponse(message: "invalid response: access_token is missing"))
                        return
                    }

                    if let rt = refreshToken {
                        self.refreshToken = rt
                    } else {
                        handler(error: .invalidResponse(message: "invalid response: refresh_token is missing"))
                        return
                    }

                    if let tt = tokenType {
                        self.tokenType = tt
                    } else {
                        self.tokenType = "bearer"
                    }
                    let lr = self.loadToken()
                    switch (lr) {
                    case .success(_, _, _, _):
                        onMainThread { self.save() }
                        handler(error: .none)
                    case .failure(let it):
                        handler(error: OtsimoError.invalidTokenError(error: it))
                    }
                } else {
                    let e = JSONDictionary["error"]
                    if e != nil {
                        handler(error: .invalidResponse(message: "request failed: error= \(e)"))
                    } else {
                        handler(error: .invalidResponse(message: "request failed: \(data)"))
                    }
                }
            }
            catch let JSONError as NSError {
                handler(error: .invalidResponse(message: "invalid response: \(JSONError)"))
            }
        }) 
        task.resume()
    }

    static func userDefaults(_ appGroup: String) -> UserDefaults {
        if appGroup == "" {
            return UserDefaults.standard
        }
        if let d = UserDefaults(suiteName: appGroup) {
            return d
        }
        Log.error("could not get shared nsuserdefaults with suitename")
        return UserDefaults.standard
    }

    internal static func migrateToSharedKeyChain(_ config: ClientConfig) {
        let defaults = Session.userDefaults(config.appGroup)

        if let s = Otsimo.sharedInstance.cache.fetchSession() {
            defaults.setValue(s.email, forKey: emailKey)
            defaults.setValue(s.profileId, forKey: userIDKey)
            defaults.synchronize()

            let account = OtsimoAccount(email: s.email, jwt: "", refresh: "", tokentype: "", sharedKeyChain: nil)

            if let result = account.readFromSecureStore() {
                let accessToken = result.data?["jwt"] as! String
                let refreshToken = result.data?["refresh"] as! String
                let tokenType = result.data?["tokentype"] as! String
                let sharedAccount = OtsimoAccount(email: s.email,
                    jwt: accessToken,
                    refresh: refreshToken,
                    tokentype: tokenType,
                    sharedKeyChain: config.sharedKeyChain)

                do {
                    if let ok = sharedAccount.readFromSecureStore() {
                        try sharedAccount.updateInSecureStore()
                        Log.info("session is migrated by update")
                    } else {
                        try sharedAccount.createInSecureStore()
                        Log.info("session is migrated by create")
                    }
                } catch {
                    Log.error("failed to migrage account information: \(error)")
                }
            }
        }
    }
}
