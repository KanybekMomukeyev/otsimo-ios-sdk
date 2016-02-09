//
//  Cache.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 28/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import OtsimoApiGrpc
import Haneke

final class OtsimoCache: CacheProtocol {
    static let catalogCache = Cache<OTSCatalog>(name: "otsimo-catalog")
    static let catalogKey = "catalog"
    static let sessionCache = Cache<OTSSessionCache>(name: "otsimo-session")
    static let sessionKey = "session"
    static let gameCache = Cache<Game>(name: "otsimo-game")
    static let gameTTL: Double = 100
    
    // Game
    func fetchGame(id: String, handler: (Game?) -> Void) {
        OtsimoCache.gameCache.fetch(key: id)
            .onFailure({_ in handler(nil)})
            .onSuccess({g in
                let now: Double = NSDate().timeIntervalSince1970
                let fetched = g.fetchedAt!.timeIntervalSince1970
                if (now - fetched) > OtsimoCache.gameTTL {
                    OtsimoCache.gameCache.remove(key: id)
                    handler(nil)
                } else {
                    handler(g)
                }
            })
    }
    
    func cacheGame(game: Game) {
        if game.gameManifest != nil {
            OtsimoCache.gameCache.set(value: game, key: game.id)
        }
    }
    
    // Catalog
    func fetchCatalog(handler: (OTSCatalog?) -> Void) {
        OtsimoCache.catalogCache.fetch(key: OtsimoCache.catalogKey)
            .onFailure({_ in handler(nil)})
            .onSuccess({c in
                let now: Double = NSDate().timeIntervalSince1970
                if now > Double(c.expiresAt) {
                    OtsimoCache.catalogCache.remove(key: OtsimoCache.catalogKey)
                    handler(nil)
                } else {
                    handler(c)
                }
            })
    }
    func cacheCatalog(catalog: OTSCatalog) {
        OtsimoCache.catalogCache.set(value: catalog, key: OtsimoCache.catalogKey)
    }
    
    // Session
    func fetchSession(handler: (OTSSessionCache?) -> Void) {
        OtsimoCache.sessionCache.fetch(key: OtsimoCache.sessionKey)
            .onFailure {_ in handler(nil)}
            .onSuccess {handler($0)}
    }
    
    func cacheSession(session: OTSSessionCache) {
        OtsimoCache.sessionCache.set(value: session, key: OtsimoCache.sessionKey)
    }
    
    func clearSession() {
        OtsimoCache.sessionCache.remove(key: OtsimoCache.sessionKey)
    }
}
