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

internal final class Connection {
    internal let config : ClientConfig
    internal let apiService: OTSApiService
    internal let catalogService: OTSCatalogService
    internal let watchService: OTSWatchService
    internal let listenerService: OTSListenerService
    internal let registryService: OTSRegistryService
    internal let contentService: OTSContentService
    internal let dashboardService: DashboardService

    internal init(config: ClientConfig) {
        self.config = config
        if (!config.useTls) {
            GRPCCall.useInsecureConnectionsForHost(config.apiGrpcUrl)
            GRPCCall.useInsecureConnectionsForHost(config.registryGrpcUrl)
            GRPCCall.useInsecureConnectionsForHost(config.catalogGrpcUrl)
            GRPCCall.useInsecureConnectionsForHost(config.listenerGrpcUrl)
            GRPCCall.useInsecureConnectionsForHost(config.watchGrpcUrl)
            GRPCCall.useInsecureConnectionsForHost(config.contentGrpcUrl)
        }
        apiService = OTSApiService(host: config.apiGrpcUrl)
        catalogService = OTSCatalogService(host: config.catalogGrpcUrl)
        watchService = OTSWatchService(host: config.watchGrpcUrl)
        listenerService = OTSListenerService(host: config.listenerGrpcUrl)
        registryService = OTSRegistryService(host: config.registryGrpcUrl)
        contentService = OTSContentService(host: config.contentGrpcUrl)
        dashboardService = DashboardService(host: config.dashboardGrpcUrl)
    }

    func getProfile(session: Session, handler: (OTSProfile?, OtsimoError) -> Void) {
        let request = OTSGetProfileRequest()
        request.id_p = session.profileID
        var RPC : ProtoRPC!
        RPC = apiService.RPCToGetProfileWithRequest(request) { response, error in
            if let response = response {
                onMainThread { handler(response, OtsimoError.None) }
            } else {
                Log.error("getProfile: Finished with error: \(error!)")
                onMainThread { handler(nil, OtsimoError.ServiceError(message: "\(error)")) }
            }
        }

        session.getAuthorizationHeader { header, err in
            switch (err) {
            case .None:
                RPC.oauth2AccessToken = header
                RPC.start()
            default:
                handler(nil, err)
            }
        }
    }

    func addChild(session: Session, child: OTSChild, handler: (OtsimoError) -> Void) {
        child.parentId = session.profileID

        var RPC : ProtoRPC!
        RPC = apiService.RPCToAddChildWithRequest(child) { response, error in
            if let response = response {
                if response.type == 0 {
                    onMainThread { handler(OtsimoError.None) }
                } else {
                    onMainThread { handler(OtsimoError.ServiceError(message: "code:\(response.type),message:\(response.message!)")) }
                }
            } else {
                Log.error("addChild, Finished with error: \(error!)")
                onMainThread { handler(OtsimoError.ServiceError(message: "\(error)")) }
            }
        }
        session.getAuthorizationHeader { header, err in
            switch (err) {
            case .None:
                RPC.oauth2AccessToken = header
                RPC.start()
            default:
                handler(err)
            }
        }
    }

    func getChild(session: Session, childId: String, handler: (res: OTSChild?, err: OtsimoError) -> Void) {
        let req = OTSGetChildRequest()
        req.childId = childId

        var RPC : ProtoRPC!

        RPC = apiService.RPCToGetChildWithRequest(req) { response, error in
            if let response = response {
                onMainThread { handler(res: response, err: .None) }
            } else {
                Log.error("getChild, Finished with error: \(error!)")
                onMainThread { handler(res: nil, err: OtsimoError.ServiceError(message: "\(error)")) }
            }
        }

        session.getAuthorizationHeader { header, err in
            switch (err) {
            case .None:
                RPC.oauth2AccessToken = header
                RPC.start()
            default:
                handler(res: nil, err: err)
            }
        }
    }

    func getChildren(session: Session, handler: (res: [OTSChild], err: OtsimoError) -> Void) {
        let req = OTSGetChildrenFromProfileRequest()
        req.profileId = session.profileID

        var RPC : ProtoRPC!

        RPC = apiService.RPCToGetChildrenWithRequest(req) { response, error in
            if let response = response {
                var r: [OTSChild] = []
                for i in 0 ..< Int(response.childrenArray_Count) {
                    let child = response.childrenArray[i] as? OTSChild
                    if let child = child {
                        r.append(child)
                    }
                }
                onMainThread { handler(res: r, err: .None) }
            } else {
                onMainThread { handler(res: [], err: OtsimoError.ServiceError(message: "\(error)")) }
                Log.error("getChildren, Finished with error: \(error!)")
            }
        }

        session.getAuthorizationHeader { header, err in
            switch (err) {
            case .None:
                RPC.oauth2AccessToken = header
                RPC.start()
            default:
                handler(res: [], err: err)
            }
        }
    }

    func updateGameEntry(session: Session, req: OTSGameEntryRequest, handler: (OtsimoError) -> Void) {
        var RPC : ProtoRPC!
        RPC = apiService.RPCToUpdateGameEntryWithRequest(req) { response, error in
            if let response = response {
                if response.type == 0 {
                    onMainThread { handler(OtsimoError.None) }
                } else {
                    onMainThread { handler(OtsimoError.ServiceError(message: "code:\(response.type),message:\(response.message!)")) }
                }
            } else {
                Log.error("updateGameEntry, Finished with error: \(error!)")
                onMainThread { handler(OtsimoError.ServiceError(message: "\(error)")) }
            }
        }

        session.getAuthorizationHeader { header, err in
            switch (err) {
            case .None:
                RPC.oauth2AccessToken = header
                RPC.start()
            default:
                handler(err)
            }
        }
    }

    func updateChildAppSound(session: Session, req: OTSSoundEnableRequest, handler: (OtsimoError) -> Void) {
        var RPC : ProtoRPC!
        RPC = apiService.RPCToSoundEnableWithRequest(req) { response, error in
            if let response = response {
                if response.type == 0 {
                    onMainThread { handler(OtsimoError.None) }
                } else {
                    onMainThread { handler(OtsimoError.ServiceError(message: "code:\(response.type),message:\(response.message!)")) }
                }
            } else {
                Log.error("updateChildAppSound, Finished with error: \(error!)")
                onMainThread { handler(OtsimoError.ServiceError(message: "\(error)")) }
            }
        }

        session.getAuthorizationHeader { header, err in
            switch (err) {
            case .None:
                RPC.oauth2AccessToken = header
                RPC.start()
            default:
                handler(err)
            }
        }
    }

    func updateProfile(session: Session, profile: OTSProfile, handler: (OtsimoError) -> Void) {
        profile.id_p = session.profileID

        var RPC : ProtoRPC!
        RPC = apiService.RPCToUpdateProfileWithRequest(profile) { response, error in
            if let response = response {
                if response.type == 0 {
                    onMainThread { handler(OtsimoError.None) }
                } else {
                    onMainThread { handler(OtsimoError.ServiceError(message: "code:\(response.type),message:\(response.message!)")) }
                }
            } else {
                Log.error("updateProfile, Finished with error: \(error!)")
                onMainThread { handler(OtsimoError.ServiceError(message: "\(error)")) }
            }
        }

        session.getAuthorizationHeader { header, err in
            switch (err) {
            case .None:
                RPC.oauth2AccessToken = header
                RPC.start()
            default:
                handler(err)
            }
        }
    }

    func updateChild(session: Session, id: String, parentID: String, child: OTSChild, handler: (OtsimoError) -> Void) {
        child.id_p = id
        child.parentId = parentID

        var RPC : ProtoRPC!
        RPC = apiService.RPCToUpdateChildWithRequest(child) { response, error in
            if let response = response {
                if response.type == 0 {
                    onMainThread { handler(OtsimoError.None) }
                } else {
                    onMainThread { handler(OtsimoError.ServiceError(message: "code:\(response.type),message:\(response.message!)")) }
                }
            } else {
                Log.error("updateChild, Finished with error: \(error!)")
                onMainThread { handler(OtsimoError.ServiceError(message: "\(error)")) }
            }
        }

        session.getAuthorizationHeader { header, err in
            switch (err) {
            case .None:
                RPC.oauth2AccessToken = header
                RPC.start()
            default:
                handler(err)
            }
        }
    }

    func getCurrentCatalog(session: Session, req: OTSCatalogPullRequest, handler: (res: OTSCatalog?, err: OtsimoError) -> Void) {
        var RPC : ProtoRPC!
        RPC = catalogService.RPCToPullWithRequest(req) { response, error in
            if let response = response {
                onMainThread { handler(res: response, err: OtsimoError.None) }
            } else {
                Log.error("getCurrentCatalog, Finished with error: \(error!)")
                onMainThread { handler(res: nil, err: OtsimoError.ServiceError(message: "\(error)")) }
            }
        }
        session.getAuthorizationHeader { header, err in
            switch (err) {
            case .None:
                RPC.oauth2AccessToken = header
                RPC.start()
            default:
                handler(res: nil, err: err)
            }
        }
    }

    func getGameRelease(session: Session, gameID: String, version: String?, onlyProduction: Bool?, handler: (res: OTSGameRelease?, err: OtsimoError) -> Void) {
        let req = OTSGetGameReleaseRequest()
        req.gameId = gameID
        req.version = version
        if let prod = onlyProduction {
            if prod {
                req.state = OTSRequestReleaseState.ProductionState
            } else {
                req.state = OTSRequestReleaseState.AllStates
            }
        } else {
            req.state = OTSRequestReleaseState.ProductionState
        }

        var RPC : ProtoRPC!

        RPC = registryService.RPCToGetReleaseWithRequest(req) { response, error in
            if let response = response {
                onMainThread { handler(res: response, err: OtsimoError.None) }
            } else {
                Log.error("getGameRelease, Finished with error: \(error!)")
                onMainThread { handler(res: nil, err: OtsimoError.ServiceError(message: "\(error)")) }
            }
        }
        session.getAuthorizationHeader { header, err in
            switch (err) {
            case .None:
                RPC.oauth2AccessToken = header
                RPC.start()
            default:
                handler(res: nil, err: err)
            }
        }
    }

    func getAllGamesStream(session: Session, handler: (OTSListItem?, done: Bool, err: OtsimoError) -> Void) {
        let req = OTSListGamesRequest()
        req.releaseState = OTSListGamesRequest_InnerState.Production
        req.limit = 32

        var RPC : ProtoRPC!

        RPC = registryService.RPCToListGamesWithRequest(req) { done, response, error in
            if let response = response {
                onMainThread { handler(response, done: false, err: OtsimoError.None) }
            } else if (!done) {
                Log.error("getAllGames, Finished with error: \(error!)")
                onMainThread { handler(nil, done: true, err: OtsimoError.ServiceError(message: "\(error)")) }
                return
            }
            if (done) {
                onMainThread { handler(nil, done: true, err: OtsimoError.None) }
            }
        }
        session.getAuthorizationHeader { header, err in
            switch (err) {
            case .None:
                RPC.oauth2AccessToken = header
                RPC.start()
            default:
                handler(nil, done: true, err: err)
            }
        }
    }

    func gamesLatestVersions(session: Session, gameIDs: [String], handler: ([OTSGameAndVersion], err: OtsimoError) -> Void) {
        let req: OTSGetLatestVersionsRequest = OTSGetLatestVersionsRequest()
        if config.onlyProduction {
            req.state = OTSRequestReleaseState.ProductionState
        } else {
            req.state = OTSRequestReleaseState.AllStates
        }
        req.gameIdsArray = NSMutableArray(array: gameIDs)

        let RPC = registryService.RPCToGetLatestVersionsWithRequest(req) { resp, err in
            if let resp = resp {
                var r: [OTSGameAndVersion] = []
                for i in 0 ..< Int(resp.resultsArray_Count) {
                    let gav = resp.resultsArray[i] as? OTSGameAndVersion
                    if let g = gav {
                        r.append(g)
                    }
                }
                onMainThread { handler(r, err: .None) }
            } else {
                onMainThread { handler([], err: OtsimoError.ServiceError(message: "\(err)")) }
            }
        }
        session.getAuthorizationHeader { header, err in
            switch (err) {
            case .None:
                RPC.oauth2AccessToken = header
                RPC.start()
            default:
                handler([], err: err)
            }
        }
    }

    func getDashboard(session: Session, childID: String, handler: (dashboard: DashboardItems?, err: OtsimoError) -> Void) {
        let req = DashboardGetRequest()

        req.profileId = session.profileID
        req.appVersion = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as! String
        req.childId = childID

        let RPC = dashboardService.RPCToGetWithRequest(req) { response, error in
            if let response = response {
                onMainThread { handler(dashboard: response, err: OtsimoError.None) }
            } else {
                onMainThread { handler(dashboard: nil, err: OtsimoError.ServiceError(message: "\(error)")) }
            }
        }

        session.getAuthorizationHeader { header, err in
            switch (err) {
            case .None:
                RPC.oauth2AccessToken = header
                RPC.start()
            default:
                handler(dashboard: nil, err: err)
            }
        }
    }

    func getContents(session: Session, req: OTSContentListRequest, handler: (ver: Int, res: [OTSContent], err: OtsimoError) -> Void) {
        req.profileId = session.profileID
        req.clientVersion = Otsimo.sdkVersion

        let RPC : ProtoRPC! = contentService.RPCToListWithRequest(req) { response, error in
            if let response = response {
                var r: [OTSContent] = []
                for i in 0 ..< Int(response.contentsArray_Count) {
                    let content = response.contentsArray[i] as? OTSContent
                    if let content = content {
                        r.append(content)
                    }
                }
                onMainThread {
                    handler(ver: Int(response.assetVersion), res: r, err: .None)
                }
            } else {
                onMainThread { handler(ver: 0, res: [], err: OtsimoError.ServiceError(message: "\(error)")) }
                Log.error("getContents, Finished with error: \(error!)")
            }
        }
        RPC.start()
    }

    func login(email: String, plainPassword: String, handler: (res: TokenResult, session: Session?) -> Void) {
        let grant_type = "password"
        let urlPath: String = "\(config.accountsServiceUrl)/login"
        let emailTrimmed = email.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let postString = "username=\(emailTrimmed)&password=\(plainPassword)&grant_type=\(grant_type)&client_id=\(config.clientID)"
        httpRequestWithTokenResult(urlPath, postString: postString, handler: handler)
    }

    func register(data: RegistrationData, handler: (res: TokenResult, session: Session?) -> Void) {
        let urlPath: String = "\(config.accountsServiceUrl)/register"
        let postString = "username=\(data.email)&password=\(data.password)&first_name=\(data.firstName)&last_name=\(data.lastName)&language=\(data.language)&client_id=\(config.clientID)"
        httpRequestWithTokenResult(urlPath, postString: postString, handler: handler)
    }

    func changePassword(session: Session, old: String, new: String, handler: (OtsimoError) -> Void) {
        let urlPath: String = "\(config.accountsServiceUrl)/update/password"
        let postString = "user_id=\(session.profileID)&old_password=\(old)&new_password=\(new)"

        session.getAuthorizationHeader { header, err in
            switch (err) {
            case .None:
                self.httpPostRequestWithToken(urlPath, postString: postString, authorization: header, handler: handler)
            default:
                handler(err)
            }
        }
    }

    func changeEmail(session: Session, old: String, new: String, handler: (OtsimoError) -> Void) {
        let urlPath: String = "\(config.accountsServiceUrl)/update/email"
        let postString = "old_email=\(old)&new_email=\(new)"

        session.getAuthorizationHeader { header, err in
            switch (err) {
            case .None:
                self.httpPostRequestWithToken(urlPath, postString: postString, authorization: header, handler: handler)
            default:
                handler(err)
            }
        }
    }

    func resetPasswrod(email: String, handler: (OtsimoError) -> Void) {
        let urlPath: String = "\(config.accountsServiceUrl)/reset"
        let postString = "email=\(email)"
        httpPostRequest(urlPath, postString: postString, handler: handler)
    }

    // http requests

    func httpRequestWithTokenResult(urlPath: String, postString: String, handler: (res: TokenResult, session: Session?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: urlPath)!)
        request.HTTPMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        request.timeoutInterval = 20
        request.cachePolicy = .ReloadIgnoringLocalAndRemoteCacheData

        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else { // check for fundamental networking error
                onMainThread { handler(res: .Error(error: .NetworkError(message: "\(error)")), session: nil) }
                return
            }
            var isOK = true
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 { // check for http errors
                isOK = false
            }

            do {
                let JSON = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))
                guard let JSONDictionary : NSDictionary = JSON as? NSDictionary else {
                    onMainThread { handler(res: .Error(error: .InvalidResponse(message: "invalid response:not a dictionary")), session: nil) }
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
                        onMainThread { handler(res: .Error(error: .InvalidResponse(message: "invalid response: access_token is missing")), session: nil) }
                        return
                    }

                    if let rt = refreshToken {
                        s.refreshToken = rt
                    } else {
                        onMainThread { handler(res: .Error(error: .InvalidResponse(message: "invalid response: refresh_token is missing")), session: nil) }
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
                        onMainThread { handler(res: .Success, session: s) }
                    case .Failure(let it):
                        onMainThread { handler(res: .Error(error: OtsimoError.InvalidTokenError(error: it)), session: nil) }
                    }
                } else {
                    let e = JSONDictionary["error"]
                    if e != nil {
                        onMainThread { handler(res: .Error(error: .InvalidResponse(message: "request failed: error= \(e)")), session: nil) }
                    } else {
                        onMainThread { handler(res: .Error(error: .InvalidResponse(message: "request failed: \(data)")), session: nil) }
                    }
                }
            }
            catch let JSONError as NSError {
                onMainThread { handler(res: .Error(error: .InvalidResponse(message: "invalid response: \(JSONError)")), session: nil) }
            }
        }
        task.resume()
    }

    func httpPostRequestWithToken(urlPath: String, postString: String, authorization: String, handler: (error: OtsimoError) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: urlPath)!)
        request.HTTPMethod = "POST"
        request.setValue("Bearer \(authorization)", forHTTPHeaderField: "authorization")
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        request.timeoutInterval = 20
        request.cachePolicy = .ReloadIgnoringLocalAndRemoteCacheData

        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else { // check for fundamental networking error
                onMainThread { handler(error: .NetworkError(message: "\(error)")) }
                return
            }
            var isOK = true
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 { // check for http errors
                isOK = false
            }

            do {
                let JSON = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))
                guard let JSONDictionary : NSDictionary = JSON as? NSDictionary else {
                    onMainThread { handler(error: .InvalidResponse(message: "invalid response:not a dictionary")) }
                    return
                }
                if isOK && JSONDictionary["error"] == nil {
                    // todo
                    onMainThread { handler(error: OtsimoError.None) }
                } else {
                    let e = JSONDictionary["error"]
                    if e != nil {
                        onMainThread { handler(error: .InvalidResponse(message: "request failed: error= \(e)")) }
                    } else {
                        onMainThread { handler(error: .InvalidResponse(message: "request failed: \(data)")) }
                    }
                }
            }
            catch let JSONError as NSError {
                onMainThread { handler(error: .InvalidResponse(message: "invalid response: \(JSONError)")) }
            }
        }
        task.resume()
    }

    func httpPostRequest(urlPath: String, postString: String, handler: (error: OtsimoError) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: urlPath)!)
        request.HTTPMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        request.timeoutInterval = 20
        request.cachePolicy = .ReloadIgnoringLocalAndRemoteCacheData

        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else { // check for fundamental networking error
                onMainThread { handler(error: .NetworkError(message: "\(error)")) }
                return
            }
            var isOK = true
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 { // check for http errors
                isOK = false
            }

            do {
                let JSON = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))
                guard let JSONDictionary : NSDictionary = JSON as? NSDictionary else {
                    onMainThread { handler(error: .InvalidResponse(message: "invalid response:not a dictionary")) }
                    return
                }
                if isOK && JSONDictionary["error"] == nil {
                    // todo
                    onMainThread { handler(error: OtsimoError.None) }
                } else {
                    let e = JSONDictionary["error"]
                    if e != nil {
                        onMainThread { handler(error: .InvalidResponse(message: "request failed: error= \(e)")) }
                    } else {
                        onMainThread { handler(error: .InvalidResponse(message: "request failed: \(data)")) }
                    }
                }
            }
            catch let JSONError as NSError {
                onMainThread { handler(error: .InvalidResponse(message: "invalid response: \(JSONError)")) }
            }
        }
        task.resume()
    }
}