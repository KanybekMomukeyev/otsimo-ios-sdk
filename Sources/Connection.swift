//
//  Connection.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 04/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import OtsimoApiGrpc
import grpc

internal final class Connection {
    internal let config: ClientConfig
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
            GRPCCall.useInsecureConnections(forHost: config.apiGrpcUrl)
            GRPCCall.useInsecureConnections(forHost: config.registryGrpcUrl)
            GRPCCall.useInsecureConnections(forHost: config.catalogGrpcUrl)
            GRPCCall.useInsecureConnections(forHost: config.listenerGrpcUrl)
            GRPCCall.useInsecureConnections(forHost: config.watchGrpcUrl)
            GRPCCall.useInsecureConnections(forHost: config.contentGrpcUrl)
        }
        apiService = OTSApiService(host: config.apiGrpcUrl)
        catalogService = OTSCatalogService(host: config.catalogGrpcUrl)
        watchService = OTSWatchService(host: config.watchGrpcUrl)
        listenerService = OTSListenerService(host: config.listenerGrpcUrl)
        registryService = OTSRegistryService(host: config.registryGrpcUrl)
        contentService = OTSContentService(host: config.contentGrpcUrl)
        dashboardService = DashboardService(host: config.dashboardGrpcUrl)
    }

    func getProfile(_ session: Session, handler: @escaping (OTSProfile?, OtsimoError) -> Void) {
        let request = OTSGetProfileRequest()
        request.id_p = session.profileID
        let RPC = apiService.rpcToGetProfile(with: request) { response, error in
            if let response = response {
                onMainThread { handler(response, OtsimoError.none) }
            } else {
                Log.error("getProfile: Finished with error: \(error!)")
                onMainThread { handler(nil, OtsimoError.serviceError(message: "\(error)")) }
            }
        }

        session.getAuthorizationHeader { header, err in
            switch (err) {
            case .none:
                RPC.oauth2AccessToken = header
                RPC.start()
            default:
                handler(nil, err)
            }
        }
    }

    func addChild(_ session: Session, child: OTSChild, handler: @escaping (OtsimoError) -> Void) {
        child.parentId = session.profileID

        let RPC = apiService.rpcToAddChild(withRequest: child) { response, error in
            if let response = response {
                if response.type == 0 {
                    onMainThread { handler(OtsimoError.none) }
                } else {
                    onMainThread { handler(OtsimoError.serviceError(message: "code:\(response.type),message:\(response.message!)")) }
                }
            } else {
                Log.error("addChild, Finished with error: \(error!)")
                onMainThread { handler(OtsimoError.serviceError(message: "\(error)")) }
            }
        }
        session.getAuthorizationHeader { header, err in
            switch (err) {
            case .none:
                RPC.oauth2AccessToken = header
                RPC.start()
            default:
                handler(err)
            }
        }
    }

    func getChild(_ session: Session, childId: String, handler: @escaping (_ res: OTSChild?, _ err: OtsimoError) -> Void) {
        let req = OTSGetChildRequest()
        req.childId = childId

        let RPC = apiService.rpcToGetChild(with: req) { response, error in
            if let response = response {
                onMainThread { handler(response, .none) }
            } else {
                Log.error("getChild, Finished with error: \(error!)")
                onMainThread { handler(nil, OtsimoError.serviceError(message: "\(error)")) }
            }
        }

        session.getAuthorizationHeader { header, err in
            switch (err) {
            case .none:
                RPC.oauth2AccessToken = header
                RPC.start()
            default:
                handler(nil, err)
            }
        }
    }

    func getChildren(_ session: Session, handler: @escaping (_ res: [OTSChild], _ err: OtsimoError) -> Void) {
        let req = OTSGetChildrenFromProfileRequest()
        req.profileId = session.profileID

        let RPC = apiService.rpcToGetChildren(with: req) { response, error in
            if let response = response {
                var r: [OTSChild] = []
                for i in 0 ..< Int(response.childrenArray_Count) {
                    let child = response.childrenArray[i] as? OTSChild
                    if let child = child {
                        r.append(child)
                    }
                }
                onMainThread { handler(r, .none) }
            } else {
                onMainThread { handler([], OtsimoError.serviceError(message: "\(error)")) }
                Log.error("getChildren, Finished with error: \(error!)")
            }
        }

        session.getAuthorizationHeader { header, err in
            switch (err) {
            case .none:
                RPC.oauth2AccessToken = header
                RPC.start()
            default:
                handler([], err)
            }
        }
    }

    func updateGameEntry(_ session: Session, req: OTSGameEntryRequest, handler: @escaping (OtsimoError) -> Void) {
        let RPC = apiService.rpcToUpdateGameEntry(with: req) { response, error in
            if let response = response {
                if response.type == 0 {
                    onMainThread { handler(OtsimoError.none) }
                } else {
                    onMainThread { handler(OtsimoError.serviceError(message: "code:\(response.type),message:\(response.message!)")) }
                }
            } else {
                Log.error("updateGameEntry, Finished with error: \(error!)")
                onMainThread { handler(OtsimoError.serviceError(message: "\(error)")) }
            }
        }

        session.getAuthorizationHeader { header, err in
            switch (err) {
            case .none:
                RPC.oauth2AccessToken = header
                RPC.start()
            default:
                handler(err)
            }
        }
    }

    func updateChildAppSound(_ session: Session, req: OTSSoundEnableRequest, handler: @escaping (OtsimoError) -> Void) {
        let RPC = apiService.rpcToSoundEnable(with: req) { response, error in
            if let response = response {
                if response.type == 0 {
                    onMainThread { handler(OtsimoError.none) }
                } else {
                    onMainThread { handler(OtsimoError.serviceError(message: "code:\(response.type),message:\(response.message!)")) }
                }
            } else {
                Log.error("updateChildAppSound, Finished with error: \(error!)")
                onMainThread { handler(OtsimoError.serviceError(message: "\(error)")) }
            }
        }

        session.getAuthorizationHeader { header, err in
            switch (err) {
            case .none:
                RPC.oauth2AccessToken = header
                RPC.start()
            default:
                handler(err)
            }
        }
    }

    func updateProfile(_ session: Session, profile: OTSProfile, handler: @escaping (OtsimoError) -> Void) {
        profile.id_p = session.profileID

        let RPC = apiService.rpcToUpdateProfile(withRequest: profile) { response, error in
            if let response = response {
                if response.type == 0 {
                    onMainThread { handler(OtsimoError.none) }
                } else {
                    onMainThread { handler(OtsimoError.serviceError(message: "code:\(response.type),message:\(response.message!)")) }
                }
            } else {
                Log.error("updateProfile, Finished with error: \(error!)")
                onMainThread { handler(OtsimoError.serviceError(message: "\(error)")) }
            }
        }

        session.getAuthorizationHeader { header, err in
            switch (err) {
            case .none:
                RPC.oauth2AccessToken = header
                RPC.start()
            default:
                handler(err)
            }
        }
    }

    func updateChild(_ session: Session, id: String, parentID: String, child: OTSChild, handler: @escaping (OtsimoError) -> Void) {
        child.id_p = id
        child.parentId = parentID

        let RPC = apiService.rpcToUpdateChild(withRequest: child) { response, error in
            if let response = response {
                if response.type == 0 {
                    onMainThread { handler(OtsimoError.none) }
                } else {
                    onMainThread { handler(OtsimoError.serviceError(message: "code:\(response.type),message:\(response.message!)")) }
                }
            } else {
                Log.error("updateChild, Finished with error: \(error!)")
                onMainThread { handler(OtsimoError.serviceError(message: "\(error)")) }
            }
        }

        session.getAuthorizationHeader { header, err in
            switch (err) {
            case .none:
                RPC.oauth2AccessToken = header
                RPC.start()
            default:
                handler(err)
            }
        }
    }

    func getCurrentCatalog(_ session: Session, req: OTSCatalogPullRequest, handler: @escaping (_ res: OTSCatalog?, _ err: OtsimoError) -> Void) {
        let RPC = catalogService.rpcToPull(with: req) { response, error in
            if let response = response {
                onMainThread { handler(response, OtsimoError.none) }
            } else {
                Log.error("getCurrentCatalog, Finished with error: \(error!)")
                onMainThread { handler(nil, OtsimoError.serviceError(message: "\(error)")) }
            }
        }
        session.getAuthorizationHeader { header, err in
            switch (err) {
            case .none:
                RPC.oauth2AccessToken = header
                RPC.start()
            default:
                handler(nil, err)
            }
        }
    }

    func getGameRelease(gameID: String, version: String?, onlyProduction: Bool?, handler: @escaping (_ res: OTSGameRelease?, _ err: OtsimoError) -> Void) {
        let req = OTSGetGameReleaseRequest()
        req.gameId = gameID
        req.version = version
        if let prod = onlyProduction {
            if prod {
                req.state = OTSRequestReleaseState.productionState
            } else {
                req.state = OTSRequestReleaseState.allStates
            }
        } else {
            req.state = OTSRequestReleaseState.productionState
        }

        let RPC = registryService.rpcToGetRelease(with: req) { response, error in
            if let response = response {
                onMainThread { handler(response, OtsimoError.none) }
            } else {
                Log.error("getGameRelease, Finished with error: \(error!)")
                onMainThread { handler(nil, OtsimoError.serviceError(message: "\(error)")) }
            }
        }
        RPC.start()
    }

    func getAllGamesStream(_ language:String?, handler: @escaping (OTSListItem?, _ done: Bool, _ err: OtsimoError) -> Void) {
        let req = OTSListGamesRequest()
        req.releaseState = OTSListGamesRequest_InnerState.production
        req.limit = 32
        req.language = language
        
        let RPC = registryService.rpcToListGames(with: req) { done, response, error in
            if let response = response {
                onMainThread { handler(response, false, OtsimoError.none) }
            } else if (!done) {
                Log.error("getAllGames, Finished with error: \(error!)")
                onMainThread { handler(nil, true, OtsimoError.serviceError(message: "\(error)")) }
                return
            }
            if (done) {
                onMainThread { handler(nil, true, OtsimoError.none) }
            }
        }
        RPC.start()
    }

    func gamesLatestVersions(gameIDs: [String], handler: @escaping ([OTSGameAndVersion], _ err: OtsimoError) -> Void) {
        let req: OTSGetLatestVersionsRequest = OTSGetLatestVersionsRequest()
        if config.onlyProduction {
            req.state = OTSRequestReleaseState.productionState
        } else {
            req.state = OTSRequestReleaseState.allStates
        }
        req.gameIdsArray = NSMutableArray(array: gameIDs)

        let RPC = registryService.rpcToGetLatestVersions(with: req) { resp, err in
            if let resp = resp {
                var r: [OTSGameAndVersion] = []
                for i in 0 ..< Int(resp.resultsArray_Count) {
                    let gav = resp.resultsArray[i] as? OTSGameAndVersion
                    if let g = gav {
                        r.append(g)
                    }
                }
                onMainThread { handler(r, .none) }
            } else {
                onMainThread { handler([], OtsimoError.serviceError(message: "\(err)")) }
            }
        }
        RPC.start()
    }

    func getDashboard(_ session: Session, childID: String, lang: String, time: Int64?, handler: @escaping (_ dashboard: DashboardItems?, _ err: OtsimoError) -> Void) {
        let req = DashboardGetRequest()
        req.profileId = session.profileID
        req.childId = childID
        req.language = lang
        req.appVersion = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        req.countryCode = (Locale.current as NSLocale).object(forKey: NSLocale.Key.countryCode) as! String
        if let t = time {
            req.lastTimeDataFetched = t
        } else {
            req.lastTimeDataFetched = 0
        }

        let RPC = dashboardService.rpcToGet(with: req) { response, error in
            if let response = response {
                onMainThread { handler(response, OtsimoError.none) }
            } else {
                onMainThread { handler(nil, OtsimoError.serviceError(message: "\(error)")) }
            }
        }

        session.getAuthorizationHeader { header, err in
            switch (err) {
            case .none:
                RPC.oauth2AccessToken = header
                RPC.start()
            default:
                handler(nil, err)
            }
        }
    }

    func getContents(_ session: Session, req: OTSContentListRequest, handler: @escaping (_ ver: Int, _ res: [OTSContent], _ err: OtsimoError) -> Void) {
        req.profileId = session.profileID
        req.clientVersion = Otsimo.sdkVersion

        let RPC: GRPCProtoCall = contentService.rpcToList(with: req) { response, error in
            if let response = response {
                var r: [OTSContent] = []
                for i in 0 ..< Int(response.contentsArray_Count) {
                    let content = response.contentsArray[i] as? OTSContent
                    if let content = content {
                        r.append(content)
                    }
                }
                onMainThread {
                    handler(Int(response.assetVersion), r, .none)
                }
            } else {
                onMainThread { handler(0, [], OtsimoError.serviceError(message: "\(error)")) }
                Log.error("getContents, Finished with error: \(error!)")
            }
        }
        RPC.start()
    }

    func getContent(_ session: Session, slug: String, handler: @escaping (_ res: OTSContent?, _ err: OtsimoError) -> Void) {
        let req = OTSContentGetRequest()
        req.slug = slug
        let RPC = contentService.rpcToGet(with: req) { response, error in
            if let response = response {
                onMainThread { handler(response, .none) }
            } else {
                onMainThread { handler(nil, OtsimoError.serviceError(message: "\(error)")) }
                Log.error("getContent, Finished with error: \(error!)")
            }
        }
        RPC.start()
    }

    func login(_ email: String, plainPassword: String, handler: @escaping (_ res: TokenResult, _ session: Session?) -> Void) {
        let grant_type = "password"
        let urlPath: String = "\(config.accountsServiceUrl)/login"
        let emailTrimmed = email.trimmingCharacters(in: CharacterSet.whitespaces)
        let postString = "username=\(emailTrimmed)&password=\(plainPassword)&grant_type=\(grant_type)&client_id=\(config.clientID)"
        httpRequestWithTokenResult(urlPath, postString: postString, handler: handler)
    }

    func login(_ connector: String, accessToken: String, handler: @escaping (_ res: TokenResult, _ session: Session?) -> Void) {
        let grant_type = "password"
        let urlPath: String = "\(config.accountsServiceUrl)/remote"
        let locale = Locale.current
        let localeIdent = (Locale.current as NSLocale).object(forKey: NSLocale.Key.identifier) as! String
        let tz = NSTimeZone.local.secondsFromGMT() / 3600
        let countryCode = (locale as NSLocale).object(forKey: NSLocale.Key.countryCode) as! String
        let postString = "connector=\(connector)&access_token=\(accessToken)&grant_type=\(grant_type)&client_id=\(config.clientID)&locale=\(localeIdent)&timezone=\(tz)&country=\(countryCode)"
        httpRequestWithTokenResult(urlPath, postString: postString, handler: handler)
    }

    func register(_ data: RegistrationData, handler: @escaping (_ res: TokenResult, _ session: Session?) -> Void) {
        let urlPath: String = "\(config.accountsServiceUrl)/register"
        let tz = NSTimeZone.local.secondsFromGMT() / 3600
        let postString = "username=\(data.email)&password=\(data.password)&first_name=\(data.firstName)&last_name=\(data.lastName)&country=\(data.country)&locale=\(data.locale)&client_id=\(config.clientID)&connector=local&timezone=\(tz)"
        httpRequestWithTokenResult(urlPath, postString: postString, handler: handler)
    }

    func changePassword(_ session: Session, old: String, new: String, handler: @escaping (OtsimoError) -> Void) {
        let urlPath: String = "\(config.accountsServiceUrl)/update/password"
        let postString = "user_id=\(session.profileID)&old_password=\(old)&new_password=\(new)"

        session.getAuthorizationHeader { header, err in
            switch (err) {
            case .none:
                self.httpPostRequestWithToken(urlPath, postString: postString, authorization: header) { d, err in
                    handler(err)
                }
            default:
                handler(err)
            }
        }
    }

    func changeEmail(_ session: Session, old: String, new: String, handler: @escaping (OtsimoError) -> Void) {
        let urlPath: String = "\(config.accountsServiceUrl)/update/email"
        let postString = "old_email=\(old)&new_email=\(new)"

        session.getAuthorizationHeader { header, err in
            switch (err) {
            case .none:
                self.httpPostRequestWithToken(urlPath, postString: postString, authorization: header) { d, err in
                    handler(err)
                }
            default:
                handler(err)
            }
        }
    }

    func getIdentities(_ session: Session, handler: @escaping ([String: String], OtsimoError) -> Void) {
        let urlPath: String = "\(config.accountsServiceUrl)/user/identities"
        session.getAuthorizationHeader { header, err in
            switch (err) {
            case .none:
                self.httpPostRequestWithToken(urlPath, postString: "", authorization: header) { d, err in
                    switch (err) {
                    case .none:
                        if let res = d as? [String: String] {
                            handler(res, .none)
                        } else {
                            handler([String: String](), OtsimoError.general(message: "invalid response"))
                        }
                    default:
                        handler([String: String](), err)
                    }
                }
            default:
                handler([String: String](), err)
            }
        }
    }

    func resetPassword(_ email: String, handler: @escaping (OtsimoError) -> Void) {
        let urlPath: String = "\(config.accountsServiceUrl)/reset"
        let postString = "email=\(email)"
        httpPostRequest(urlPath, postString: postString, handler: handler)
    }

    // http requests

    func httpRequestWithTokenResult(_ urlPath: String, postString: String, handler: @escaping (_ res: TokenResult, _ session: Session?) -> Void) {
        var request = URLRequest(url: URL(string: urlPath)!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = postString.data(using: String.Encoding.utf8)
        request.timeoutInterval = 20
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil && data != nil else { // check for fundamental networking error
                onMainThread { handler(.error(error: .networkError(message: "\(error)")), nil) }
                return
            }
            var isOK = true
            if let httpStatus = response as? HTTPURLResponse , httpStatus.statusCode != 200 { // check for http errors
                isOK = false
            }

            do {
                let JSON = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0))
                guard let JSONDictionary: NSDictionary = JSON as? NSDictionary else {
                    onMainThread { handler(.error(error: .invalidResponse(message: "invalid response:not a dictionary")), nil) }
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
                        onMainThread { handler(.error(error: .invalidResponse(message: "invalid response: access_token is missing")), nil) }
                        return
                    }

                    if let rt = refreshToken {
                        s.refreshToken = rt
                    } else {
                        onMainThread { handler(.error(error: .invalidResponse(message: "invalid response: refresh_token is missing")), nil) }
                        return
                    }

                    if let tt = tokenType {
                        s.tokenType = tt
                    } else {
                        s.tokenType = "bearer"
                    }
                    let lr = s.loadToken()
                    switch (lr) {
                    case .success(_, _, _, _):
                        onMainThread { handler(.success, s) }
                    case .failure(let it):
                        onMainThread { handler(.error(error: OtsimoError.invalidTokenError(error: it)), nil) }
                    }
                } else {
                    let e = JSONDictionary["error"]
                    if e != nil {
                        onMainThread { handler(.error(error: .invalidResponse(message: "request failed: error= \(e)")), nil) }
                    } else {
                        onMainThread { handler(.error(error: .invalidResponse(message: "request failed: \(data)")), nil) }
                    }
                }
            }
            catch let JSONError as NSError {
                onMainThread { handler(.error(error: .invalidResponse(message: "invalid response: \(JSONError)")), nil) }
            }
        }) 
        task.resume()
    }

    func httpPostRequest(_ urlPath: String, postString: String, handler: @escaping (_ error: OtsimoError) -> Void) {
        var request = URLRequest(url: URL(string: urlPath)!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = postString.data(using: String.Encoding.utf8)
        request.timeoutInterval = 20
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil && data != nil else { // check for fundamental networking error
                onMainThread { handler(.networkError(message: "\(error)")) }
                return
            }
            var isOK = true
            if let httpStatus = response as? HTTPURLResponse , httpStatus.statusCode != 200 { // check for http errors
                isOK = false
            }

            do {
                let JSON = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0))
                guard let JSONDictionary: NSDictionary = JSON as? NSDictionary else {
                    onMainThread { handler(.invalidResponse(message: "invalid response:not a dictionary")) }
                    return
                }
                if isOK && JSONDictionary["error"] == nil {
                    // todo
                    onMainThread { handler(OtsimoError.none) }
                } else {
                    let e = JSONDictionary["error"]
                    if e != nil {
                        onMainThread { handler(.invalidResponse(message: "request failed: error= \(e)")) }
                    } else {
                        onMainThread { handler(.invalidResponse(message: "request failed: \(data)")) }
                    }
                }
            }
            catch let JSONError as NSError {
                onMainThread { handler(.invalidResponse(message: "invalid response: \(JSONError)")) }
            }
        }) 
        task.resume()
    }

    func httpPostRequestWithToken(_ urlPath: String, postString: String, authorization: String,
        handler: @escaping (NSDictionary?, _ error: OtsimoError) -> Void) {
            var request = URLRequest(url: URL(string: urlPath)!)
            request.httpMethod = "POST"
            request.setValue("Bearer \(authorization)", forHTTPHeaderField: "authorization")
            request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = postString.data(using: String.Encoding.utf8)
            request.timeoutInterval = 20
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

            let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                guard error == nil && data != nil else { // check for fundamental networking error
                    onMainThread { handler(nil, .networkError(message: "\(error)")) }
                    return
                }
                var isOK = true
                if let httpStatus = response as? HTTPURLResponse , httpStatus.statusCode != 200 { // check for http errors
                    isOK = false
                }
                do {
                    let JSON = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0))
                    guard let JSONDictionary: NSDictionary = JSON as? NSDictionary else {
                        onMainThread { handler(nil, .invalidResponse(message: "invalid response:not a dictionary")) }
                        return
                    }
                    if isOK && JSONDictionary["error"] == nil {
                        onMainThread { handler(JSONDictionary, OtsimoError.none) }
                    } else {
                        let e = JSONDictionary["error"]
                        if e != nil {
                            onMainThread { handler(nil, .invalidResponse(message: "request failed: error= \(e)")) }
                        } else {
                            onMainThread { handler(nil, .invalidResponse(message: "request failed: \(data)")) }
                        }
                    }
                }
                catch let JSONError as NSError {
                    onMainThread { handler(nil, .invalidResponse(message: "invalid response: \(JSONError)")) }
                }
            }) 
            task.resume()
    }
}
