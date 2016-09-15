//
//  Account.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 25/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import OtsimoApiGrpc

public protocol AccountApi {

    func login(_ email: String, password: String, handler: (_ res: TokenResult) -> Void)

    func login(_ connector: String, accessToken: String, handler: (_ res: TokenResult) -> Void)

    func register(_ data: RegistrationData, handler: (_ res: TokenResult) -> Void)

    func logout()

    func changeEmail(_ newEmail: String, handler: (OtsimoError) -> Void)

    func changePassword(_ old: String, newPassword: String, handler: (OtsimoError) -> Void)

    func resetPassword(_ email: String, handler: (_ res: OtsimoError) -> Void)

    func userIdentities(_ handler: ([String: String], OtsimoError) -> Void)
}

public protocol ProfileApi {

    func getProfile(_ handler: (OTSProfile?, OtsimoError) -> Void)

    func updateProfile(_ profile: OTSProfile, handler: (_ error: OtsimoError) -> Void)
}

public protocol ChildApi {
    func addChild(_ child:OTSChild, handler: (_ res: OtsimoError) -> Void)

    func getChild(_ id: String, handler: (_ res: OTSChild?, _ err: OtsimoError) -> Void)

    func getChildren(_ handler: (_ res: [OTSChild], _ err: OtsimoError) -> Void)

    func addGameToChild(_ gameID: String, childID: String, index: Int32, settings: Data, handler: (_ error: OtsimoError) -> Void)

    func updateActivationGame(_ gameID: String, childID: String, activate: Bool, handler: (_ error: OtsimoError) -> Void)

    func updateSettings(_ gameID: String, childID: String, settings: Data, handler: (_ error: OtsimoError) -> Void)

    func updateDashboardIndex(_ gameID: String, childID: String, index: Int32, handler: (_ error: OtsimoError) -> Void)

    func updateChild(_ childID: String, child: OTSChild, handler: (_ error: OtsimoError) -> Void)

    func enableSound(_ childID: String, enable: Bool, handler: (_ error: OtsimoError) -> Void)
}

public protocol GameApi {
    func getGame(_ id: String, handler: (Game?, _ error: OtsimoError) -> Void)

    func getAllGames(_ language:String?, handler: (Game?, _ done: Bool, _ error: OtsimoError) -> Void)

    func getGameRelease(_ id: String, version: String?, onlyProduction: Bool?, handler: (OTSGameRelease?, _ error: OtsimoError) -> Void)

    func gamesLatestVersions(_ gameIDs: [String], handler: (_ result: [OTSGameAndVersion], _ error: OtsimoError) -> Void)
}

public protocol CatalogApi {
    func getCatalog(_ handler: (OTSCatalog?, OtsimoError) -> Void)
}

public protocol WatchApi {
    func startWatch(_ callback: (OTSWatchEvent) -> Void) -> (watch: WatchProtocol?, error: OtsimoError)
}

public protocol DashboardApi {
    func dashboard(_ childID: String, lang: String, cacheTime: Int64?, handler: (DashboardItems?, OtsimoError) -> Void)
}

public enum ContentSort {
    case weightAsc
    case weightDsc
    case dateAsc
    case dateDsc
}

public protocol WikiApi {
    func contentsByCategory(_ category: String, sort: ContentSort, limit: Int32?, offset: Int32?, language: String, callback: (Int, [OTSContent], OtsimoError) -> Void)
    func contentsByQuery(_ query: OTSContentListRequest, callback: (Int, [OTSContent], OtsimoError) -> Void)
    func wikiSegments() -> [SelfLearningSegment]
    func content(_ slug: String, handler: (OTSContent?, OtsimoError) -> Void)
}

public protocol CacheProtocol {
    // Game
    func fetchGame(_ id: String, handler: (_ game: Game?, _ isExpired: Bool) -> Void)
    func cacheGame(_ game: Game)
    // Catalog
    func fetchCatalog(_ handler: (OTSCatalog?) -> Void)
    func cacheCatalog(_ catalog: OTSCatalog)
    // Session
    @available( *, deprecated : 1.1)
    func fetchSession() -> SessionCache?
    @available( *, deprecated : 1.1)
    func cacheSession(_ session: SessionCache)
    @available( *, deprecated : 1.1)
    func clearSession()
}

public protocol OtsimoAnalyticsProtocol {
    func customEvent(_ event: String, payload: [String: AnyObject])
    func customEvent(_ event: String, childID: String?, game: OTSGameInfo?, payload: [String: AnyObject])
    func appEvent(_ event: String, payload: [String: AnyObject])
    func start(_ session: Session)
    func stop(_ error: NSError?)
}

public protocol WatchProtocol {
    func stop(_ error: NSError?)
    func restart()
}
