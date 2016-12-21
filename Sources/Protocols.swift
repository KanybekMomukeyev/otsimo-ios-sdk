//
//  Account.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 25/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import OtsimoApiGrpc

public protocol AccountApi {

    func login(email: String, password: String, handler: @escaping(TokenResult) -> Void)

    func login(connector: String, accessToken: String, handler: @escaping(TokenResult) -> Void)

    func register(data: RegistrationData, handler: @escaping(TokenResult) -> Void)

    func logout()

    func changeEmail(newEmail: String, handler: @escaping(OtsimoError) -> Void)

    func changePassword(old: String, newPassword: String, handler: @escaping (OtsimoError) -> Void)

    func resetPassword(email: String, handler: @escaping(OtsimoError) -> Void)

    func userIdentities(handler: @escaping([String: String], OtsimoError) -> Void)
}

public protocol ProfileApi {

    func getProfile(_ handler: @escaping (OTSProfile?, OtsimoError) -> Void)

    func updateProfile(_ profile: OTSProfile, handler: @escaping(_ error: OtsimoError) -> Void)
}

public protocol ChildApi {
    func addChild(child: OTSChild, handler: @escaping(_ res: OtsimoError) -> Void)

    func getChild(childID: String, handler: @escaping(_ res: OTSChild?, _ err: OtsimoError) -> Void)

    func getChildren(handler: @escaping(_ res: [OTSChild], _ err: OtsimoError) -> Void)

    func addGameToChild(gameID: String, childID: String, index: Int32, settings: Data, handler: @escaping(_ error: OtsimoError) -> Void)

    func updateActivationGame(gameID: String, childID: String, activate: Bool, handler: @escaping (_ error: OtsimoError) -> Void)

    func updateSettings(gameID: String, childID: String, settings: Data, handler: @escaping (_ error: OtsimoError) -> Void)

    func updateDashboardIndex(gameID: String, childID: String, index: Int32, handler: @escaping (_ error: OtsimoError) -> Void)

    func updateChild(childID: String, child: OTSChild, handler: @escaping(_ error: OtsimoError) -> Void)

    func enableSound(childID: String, enable: Bool, handler: @escaping (_ error: OtsimoError) -> Void)
}

public protocol GameApi {
    func getGame(id: String, handler: @escaping(Game?, _ error: OtsimoError) -> Void)

    func getAllGames(language: String?, handler: @escaping(Game?, _ done: Bool, _ error: OtsimoError) -> Void)

    func getGameRelease(id: String, version: String?, onlyProduction: Bool?, handler: @escaping(OTSGameRelease?, _ error: OtsimoError) -> Void)

    func gamesLatestVersions(gameIDs: [String], handler: @escaping(_ result: [OTSGameAndVersion], _ error: OtsimoError) -> Void)
}

public protocol CatalogApi {
    func getCatalog(handler: @escaping(OTSCatalog?, OtsimoError) -> Void)
}

public protocol WatchApi {
    func startWatch(callback: @escaping(OTSWatchEvent) -> Void) -> (watch: WatchProtocol?, error: OtsimoError)
}

public protocol DashboardApi {
    func dashboard(childID: String, lang: String, cacheTime: Int64?, handler: @escaping (DashboardItems?, OtsimoError) -> Void)
}

public enum ContentSort {
    case weightAsc
    case weightDsc
    case dateAsc
    case dateDsc
}

public protocol WikiApi {
    func contentsByCategory(_ category: String, sort: ContentSort, limit: Int32?, offset: Int32?, language: String, callback: @escaping (Int, [OTSContent], OtsimoError) -> Void)
    func contentsByQuery(_ query: OTSContentListRequest, callback: @escaping (Int, [OTSContent], OtsimoError) -> Void)
    func wikiSegments() -> [SelfLearningSegment]
    func content(_ slug: String, handler: @escaping (OTSContent?, OtsimoError) -> Void)
}

public protocol CacheProtocol {
    // Game
    func fetchGame(_ id: String, handler: (_ game: Game?, _ isExpired: Bool) -> Void)
    func cacheGame(_ game: Game)
    // Catalog
    func fetchCatalog(_ handler: (OTSCatalog?) -> Void)
    func cacheCatalog(_ catalog: OTSCatalog)
    // Session
    @available( *, deprecated: 1.1)
    func fetchSession() -> SessionCache?
    @available( *, deprecated: 1.1)
    func cacheSession(_ session: SessionCache)
    @available( *, deprecated: 1.1)
    func clearSession()
}

public protocol OtsimoAnalyticsProtocol {
    func customEvent(event: String, payload: [String: AnyObject])
    func customEvent(event: String, childID: String?, game: OTSGameInfo?, payload: [String: AnyObject])
    func appEvent(event: String, payload: [String: AnyObject])
    func start(session: Session)
    func stop(error: Error?)
}

public protocol WatchProtocol {
    func stop(error: Error?)
    func restart()
}
