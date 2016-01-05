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
                handler(response, OtsimoError.None)
            } else {
                handler(nil, OtsimoError.ServiceError(message: "\(error)"))
                NSLog("getProfile: Finished with error: \(error!)")
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
                    handler(OtsimoError.None)
                } else {
                    handler(OtsimoError.ServiceError(message: "code:\(response.type),message:\(response.message!)"))
                }
            } else {
                handler(OtsimoError.ServiceError(message: "\(error)"))
                NSLog("addChild, Finished with error: \(error!)")
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
    
    func httpRequestWithTokenResult(urlPath: String, postString: String, handler: (res: TokenResult, session: Session?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: urlPath)!)
        request.HTTPMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        request.timeoutInterval = 20
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {data, response, error in
            guard error == nil && data != nil else {// check for fundamental networking error
                handler(res: .Error(error: .NetworkError(message: "\(error)")), session: nil)
                return
            }
            var isOK = true
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {// check for http errors
                isOK = false
            }
            
            do {
                let JSON = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))
                guard let JSONDictionary : NSDictionary = JSON as? NSDictionary else {
                    handler(res: .Error(error: .InvalidResponse(message: "invalid response:not a dictionary")), session: nil)
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
                        handler(res: .Error(error: .InvalidResponse(message: "invalid response: access_token is missing")), session: nil)
                        return
                    }
                    
                    if let rt = refreshToken {
                        s.refreshToken = rt
                    } else {
                        handler(res: .Error(error: .InvalidResponse(message: "invalid response: refresh_token is missing")), session: nil)
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
                        handler(res: .Success, session: s)
                    case .Failure(let it):
                        handler(res: .Error(error: OtsimoError.InvalidTokenError(error: it)), session: nil)
                    }
                } else {
                    let e = JSONDictionary["error"]
                    if e != nil {
                        handler(res: .Error(error: .InvalidResponse(message: "request failed: error= \(e)")), session: nil)
                    } else {
                        handler(res: .Error(error: .InvalidResponse(message: "request failed: \(data)")), session: nil)
                    }
                }
            }
            catch let JSONError as NSError {
                handler(res: .Error(error: .InvalidResponse(message: "invalid response: \(JSONError)")), session: nil)
            }
        }
        task.resume()
    }
}