//
//  Account.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 25/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import OtsimoApiGrpc

public protocol AccountApi {

    func login(email: String, password: String, handler: (res: TokenResult) -> Void)

    func register(data: RegistrationData, handler: (res: TokenResult) -> Void)

    func logout()

    func changeEmail(newEmail: String, handler: (OtsimoError) -> Void)

    func changePassword(old: String, newPassword: String, handler: (OtsimoError) -> Void)

    func resetPassword(email: String, handler: (res: OtsimoError) -> Void)
}

public protocol ProfileApi {

    func getProfile(handler: (OTSProfile?, OtsimoError) -> Void)

    func updateProfile(profile: OTSProfile, handler: (error: OtsimoError) -> Void)
}

public protocol ChildApi {
    func addChild(firstName: String, lastName: String, gender: OTSGender,
        birthDay: NSDate, language: String, handler: (res: OtsimoError) -> Void)

    func getChild(id: String, handler: (res: OTSChild?, err: OtsimoError) -> Void)

    func getChildren(handler: (res: [OTSChild], err: OtsimoError) -> Void)

    func addGameToChild(gameID: String, childID: String, index: Int32, settings: NSData, handler: (error: OtsimoError) -> Void)

    func updateActivationGame(gameID: String, childID: String, activate: Bool, handler: (error: OtsimoError) -> Void)

    func updateSettings(gameID: String, childID: String, settings: NSData, handler: (error: OtsimoError) -> Void)

    func updateDashboardIndex(gameID: String, childID: String, index: Int32, handler: (error: OtsimoError) -> Void)

    func updateChild(childID: String, child: OTSChild, handler: (error: OtsimoError) -> Void)

    func enableSound(childID: String, enable: Bool, handler: (error: OtsimoError) -> Void)
}

public protocol GameApi {
    func getGame(id: String, handler: (Game?, error: OtsimoError) -> Void)

    func getAllGames(handler: (Game?, done: Bool, error: OtsimoError) -> Void)

    func getGameRelease(id: String, version: String?, onlyProduction: Bool?, handler: (OTSGameRelease?, error: OtsimoError) -> Void)

    func gamesLatestVersions(gameIDs: [String], handler: (result: [OTSGameAndVersion], error: OtsimoError) -> Void)
}

public protocol CatalogApi {
    func getCatalog(handler: (OTSCatalog?, OtsimoError) -> Void)
}

public protocol WatchApi {
    func startWatch(callback: (OTSWatchEvent) -> Void) -> (watch: WatchProtocol?, error: OtsimoError)
}

public protocol DashboardApi {
    func dashboard(childID: String, lang: String, cacheTime: Int64?, handler: (DashboardItems?, OtsimoError) -> Void)
}

public enum ContentSort {
    case WeightAsc
    case WeightDsc
    case DateAsc
    case DateDsc
}

public protocol WikiApi {
    func contentsByCategory(category: String, sort: ContentSort, limit: Int32?, offset: Int32?, language: String, callback: (Int, [OTSContent], OtsimoError) -> Void)
    func contentsByQuery(query: OTSContentListRequest, callback: (Int, [OTSContent], OtsimoError) -> Void)
    func wikiSegments() -> [SelfLearningSegment]
    func content(slug: String, handler: (OTSContent?, OtsimoError) -> Void)
}

public protocol CacheProtocol {
    // Game
    func fetchGame(id: String, handler: (game: Game?, isExpired: Bool) -> Void)
    func cacheGame(game: Game)
    // Catalog
    func fetchCatalog(handler: (OTSCatalog?) -> Void)
    func cacheCatalog(catalog: OTSCatalog)
    // Session
    func fetchSession() -> SessionCache?
    func cacheSession(session: SessionCache)
    func clearSession()
}

public protocol OtsimoAnalyticsProtocol {
    func customEvent(event: String, payload: [String : AnyObject])
    func customEvent(event: String, childID: String?, game: OTSGameInfo?, payload: [String: AnyObject])
    func appEvent(event: String, payload: [String : AnyObject])
    func start(session: Session)
    func stop(error: NSError?)
}

public protocol WatchProtocol {
    func stop(error: NSError?)
    func restart()
}
