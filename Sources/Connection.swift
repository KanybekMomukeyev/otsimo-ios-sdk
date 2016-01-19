//
//  Connection.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 04/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import OtsimoApiGrpc
import gRPC

internal class Connection {
    internal let config : ClientConfig
    internal let apiService: OTSApiService
    
    internal init(config: ClientConfig) {
        self.config = config
        if (!config.useTls) {
            GRPCCall.useInsecureConnectionsForHost(config.apiGrpcUrl)
            GRPCCall.useInsecureConnectionsForHost(config.registryGrpcUrl)
        }
        apiService = OTSApiService(host: config.apiGrpcUrl)
    }
    
    func getProfile(session: Session, handler: (OTSProfile?, OtsimoError) -> Void) {
        let request = OTSGetProfileRequest()
        request.id_p = session.profileID
        var RPC : ProtoRPC!
        RPC = apiService.RPCToGetProfileWithRequest(request) {response, error in
            if let response = response {
                session.profile = response // cache return value
                onMainThread {handler(response, OtsimoError.None)}
            } else {
                print("getProfile: Finished with error: \(error!)")
                onMainThread {handler(nil, OtsimoError.ServiceError(message: "\(error)"))}
            }
        }
        if session.isAuthenticated {
            RPC.requestHeaders["Authorization"] = "\(session.tokenType) \(session.accessToken)"
            RPC.start()
        } else {
            handler(nil, OtsimoError.NotLoggedIn(message: "is not authenticated"))
        }
    }
    
    func addChild(session: Session, child: OTSChild, handler: (OtsimoError) -> Void) {
        child.parentId = session.profileID
        
        var RPC : ProtoRPC!
        RPC = apiService.RPCToAddChildWithRequest(child) {response, error in
            if let response = response {
                if response.type == 0 {
                    onMainThread {handler(OtsimoError.None)}
                } else {
                    onMainThread {handler(OtsimoError.ServiceError(message: "code:\(response.type),message:\(response.message!)"))}
                }
            } else {
                print("addChild, Finished with error: \(error!)")
                onMainThread {handler(OtsimoError.ServiceError(message: "\(error)"))}
            }
        }
        if session.isAuthenticated {
            RPC.requestHeaders["Authorization"] = "\(session.tokenType) \(session.accessToken)"
            RPC.start()
        } else {
            handler(OtsimoError.NotLoggedIn(message: "is not authenticated"))
        }
    }
    
    func getChild(session: Session, childId: String, handler: (res: OTSChild?, err: OtsimoError) -> Void) {
        let req = OTSGetChildRequest()
        req.childId = childId
        
        var RPC : ProtoRPC!
        
        RPC = apiService.RPCToGetChildWithRequest(req) {response, error in
            if let response = response {
                onMainThread {handler(res: response, err: .None)}
            } else {
                print("getChild, Finished with error: \(error!)")
                onMainThread {handler(res: nil, err: OtsimoError.ServiceError(message: "\(error)"))}
            }
        }
        
        if session.isAuthenticated {
            RPC.requestHeaders["Authorization"] = "\(session.tokenType) \(session.accessToken)"
            RPC.start()
        } else {
            handler(res: nil, err: OtsimoError.NotLoggedIn(message: "is not authenticated"))
        }
    }
    
    func getChildren(session: Session, handler: (res: [OTSChild], err: OtsimoError) -> Void) {
        let req = OTSGetChildrenFromProfileRequest()
        req.profileId = session.profileID
        
        var RPC : ProtoRPC!
        
        RPC = apiService.RPCToGetChildrenWithRequest(req) {response, error in
            if let response = response {
                var r: [OTSChild] = []
                for i in 0..<Int(response.childrenArray_Count) {
                    let child = response.childrenArray[i] as? OTSChild
                    if let child = child {
                        r.append(child)
                    }
                }
                onMainThread {handler(res: r, err: .None)}
            } else {
                onMainThread {handler(res: [], err: OtsimoError.ServiceError(message: "\(error)"))}
                print("getChildren, Finished with error: \(error!)")
            }
        }
        
        if session.isAuthenticated {
            RPC.requestHeaders["Authorization"] = "\(session.tokenType) \(session.accessToken)"
            RPC.start()
        } else {
            handler(res: [], err: OtsimoError.NotLoggedIn(message: "is not authenticated"))
        }
    }
    
    func updateGameEntry(session: Session, req: OTSGameEntryRequest, handler: (OtsimoError) -> Void) {
        var RPC : ProtoRPC!
        RPC = apiService.RPCToUpdateGameEntryWithRequest(req) {response, error in
            if let response = response {
                if response.type == 0 {
                    onMainThread {handler(OtsimoError.None)}
                } else {
                    onMainThread {handler(OtsimoError.ServiceError(message: "code:\(response.type),message:\(response.message!)"))}
                }
            } else {
                print("updateGameEntry, Finished with error: \(error!)")
                onMainThread {handler(OtsimoError.ServiceError(message: "\(error)"))}
            }
        }
        
        if session.isAuthenticated {
            RPC.requestHeaders["Authorization"] = "\(session.tokenType) \(session.accessToken)"
            RPC.start()
        } else {
            handler(OtsimoError.NotLoggedIn(message: "is not authenticated"))
        }
    }
    
    func updateProfile(session: Session, profile: OTSProfile, handler: (OtsimoError) -> Void) {
        profile.id_p = session.profileID
        
        var RPC : ProtoRPC!
        RPC = apiService.RPCToUpdateProfileWithRequest(profile) {response, error in
            if let response = response {
                if response.type == 0 {
                    onMainThread {handler(OtsimoError.None)}
                } else {
                    onMainThread {handler(OtsimoError.ServiceError(message: "code:\(response.type),message:\(response.message!)"))}
                }
            } else {
                NSLog("updateProfile, Finished with error: \(error!)")
                onMainThread {handler(OtsimoError.ServiceError(message: "\(error)"))}
            }
        }
        
        if session.isAuthenticated {
            RPC.requestHeaders["Authorization"] = "\(session.tokenType) \(session.accessToken)"
            RPC.start()
        } else {
            handler(OtsimoError.NotLoggedIn(message: "is not authenticated"))
        }
    }
    
    func login(email: String, plainPassword: String, handler: (res: TokenResult, session: Session?) -> Void) {
        let grant_type = "password"
        let urlPath: String = "\(config.accountsServiceUrl)/login"
        let emailTrimmed = email.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let postString = "username=\(emailTrimmed)&password=\(plainPassword)&grant_type=\(grant_type)"
        httpRequestWithTokenResult(urlPath, postString: postString, handler: handler)
    }
    
    func register(data: RegistrationData, handler: (res: TokenResult, session: Session?) -> Void) {
        let urlPath: String = "\(config.accountsServiceUrl)/register"
        let postString = "username=\(data.email)&password=\(data.password)&first_name=\(data.firstName)&last_name=\(data.lastName)&language=\(data.language)"
        httpRequestWithTokenResult(urlPath, postString: postString, handler: handler)
    }
    
    func changePassword(session: Session, old: String, new: String, handler: (OtsimoError) -> Void) {
        let urlPath: String = "\(config.accountsServiceUrl)/update/password"
        let postString = "user_id=\(session.profileID)&old_password=\(old)&new_password=\(new)"
        httpPostRequestWithToken(urlPath, postString: postString, authorization: "\(session.tokenType) \(session.accessToken)", handler: handler)
    }
    
    func changeEmail(session: Session, old: String, new: String, handler: (OtsimoError) -> Void) {
        let urlPath: String = "\(config.accountsServiceUrl)/update/email"
        let postString = "old_email=\(old)&new_email=\(new)"
        httpPostRequestWithToken(urlPath, postString: postString, authorization: "\(session.tokenType) \(session.accessToken)", handler: handler)
    }
    
    
    
    func httpRequestWithTokenResult(urlPath: String, postString: String, handler: (res: TokenResult, session: Session?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: urlPath)!)
        request.HTTPMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        request.timeoutInterval = 20
        request.cachePolicy = .ReloadIgnoringLocalAndRemoteCacheData
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {data, response, error in
            guard error == nil && data != nil else {// check for fundamental networking error
                onMainThread {handler(res: .Error(error: .NetworkError(message: "\(error)")), session: nil)}
                return
            }
            var isOK = true
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {// check for http errors
                isOK = false
            }
            
            do {
                let JSON = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))
                guard let JSONDictionary : NSDictionary = JSON as? NSDictionary else {
                    onMainThread {handler(res: .Error(error: .InvalidResponse(message: "invalid response:not a dictionary")), session: nil)}
                    return
                }
                if isOK && JSONDictionary["error"] == nil {
                    let accessToken: String? = JSONDictionary["access_token"] as? String
                    let refreshToken: String? = JSONDictionary["refresh_token"] as? String
                    let tokenType: String? = JSONDictionary["token_type"] as? String
                    let s = Session(config: self.config)
                    
                    if let at = accessToken {
                        s.accessToken = at
                    } else {
                        onMainThread {handler(res: .Error(error: .InvalidResponse(message: "invalid response: access_token is missing")), session: nil)}
                        return
                    }
                    
                    if let rt = refreshToken {
                        s.refreshToken = rt
                    } else {
                        onMainThread {handler(res: .Error(error: .InvalidResponse(message: "invalid response: refresh_token is missing")), session: nil)}
                        return
                    }
                    
                    if let tt = tokenType {
                        s.tokenType = tt
                    } else {
                        s.tokenType = "bearer"
                    }
                    let lr = s.loadToken()
                    switch (lr) {
                    case .Success(_, _, _, _):
                        onMainThread {handler(res: .Success, session: s)}
                    case .Failure(let it):
                        onMainThread {handler(res: .Error(error: OtsimoError.InvalidTokenError(error: it)), session: nil)}
                    }
                } else {
                    let e = JSONDictionary["error"]
                    if e != nil {
                        onMainThread {handler(res: .Error(error: .InvalidResponse(message: "request failed: error= \(e)")), session: nil)}
                    } else {
                        onMainThread {handler(res: .Error(error: .InvalidResponse(message: "request failed: \(data)")), session: nil)}
                    }
                }
            }
            catch let JSONError as NSError {
                onMainThread {handler(res: .Error(error: .InvalidResponse(message: "invalid response: \(JSONError)")), session: nil)}
            }
        }
        task.resume()
    }
    
    func httpPostRequestWithToken(urlPath: String, postString: String, authorization: String, handler: (error: OtsimoError) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: urlPath)!)
        request.HTTPMethod = "POST"
        request.setValue(authorization, forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        request.timeoutInterval = 20
        request.cachePolicy = .ReloadIgnoringLocalAndRemoteCacheData
        print("sending data to", urlPath, " data:", postString)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {data, response, error in
            guard error == nil && data != nil else {// check for fundamental networking error
                onMainThread {handler(error: .NetworkError(message: "\(error)"))}
                return
            }
            var isOK = true
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {// check for http errors
                isOK = false
            }
            
            do {
                let JSON = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))
                guard let JSONDictionary : NSDictionary = JSON as? NSDictionary else {
                    onMainThread {handler(error: .InvalidResponse(message: "invalid response:not a dictionary"))}
                    return
                }
                if isOK && JSONDictionary["error"] == nil {
                    // todo
                    onMainThread {handler(error: OtsimoError.None)}
                } else {
                    let e = JSONDictionary["error"]
                    if e != nil {
                        onMainThread {handler(error: .InvalidResponse(message: "request failed: error= \(e)"))}
                    } else {
                        onMainThread {handler(error: .InvalidResponse(message: "request failed: \(data)"))}
                    }
                }
            }
            catch let JSONError as NSError {
                onMainThread {handler(error: .InvalidResponse(message: "invalid response: \(JSONError)"))}
            }
        }
        task.resume()
    }
}