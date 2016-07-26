//
//  Cache.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 28/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import OtsimoApiGrpc
import RealmSwift

let store = try! Realm()

class CatalogCache: Object {
    dynamic var id: String = "catalog"
    dynamic var data = NSData()
    override class func primaryKey() -> String? {
        return "id"
    }

    func getCatalog() -> OTSCatalog? {
        do {
            let cat = try OTSCatalog(data: data)
            return cat
        } catch {
            Log.error("failed to parse catalog:\(error)")
            return nil
        }
    }
}

public class SettingsCache: Object {
    public dynamic var id: String = ""
    public dynamic var data: NSData = NSData()

    override public class func primaryKey() -> String? {
        return "id"
    }

    static var storage: Results<SettingsCache> {
        return store.objects(SettingsCache)
    }

    public func gameSettings() -> GameSettings? {
        return GameSettings.fromData(data)
    }

    public func save() {
        do {
            try store.write {
                store.add(self, update: true)
            }
        } catch(let error) {
            Log.error("failed to store,err=\(error)")
        }
    }

    static func createID(gameid: String, version: String) -> String {
        return "\(gameid)_\(version)"
    }
}

public class KeyValueStoreCache: Object {
    public dynamic var id: String = ""
    public dynamic var data: NSData = NSData()

    override public class func primaryKey() -> String? {
        return "id"
    }

    static var storage: Results<KeyValueStoreCache> {
        return store.objects(KeyValueStoreCache)
    }

    public func keyvalueStore() -> GameKeyValueStore? {
        return GameKeyValueStore.fromData(data)
    }

    public func save() {
        do {
            try store.write {
                store.add(self, update: true)
            }
        } catch(let error) {
            Log.error("failed to store,err=\(error)")
        }
    }

    static func createID(gameid: String, version: String, language: String) -> String {
        return "\(gameid)_\(version)_\(language)"
    }
}

@available( *, deprecated = 1.1)
public class SessionCache: Object {
    dynamic var id: String = "session"
    dynamic var profileId: String = ""
    dynamic var email: String = ""
    public override class func primaryKey() -> String? {
        return "id"
    }
}

public class GameCache: Object {
    dynamic var gameId: String = ""

    dynamic var productionVersion: String = ""

    dynamic var latestVersion: String = ""

    dynamic var latestState: Int32 = 0

    dynamic var fetchedAt: NSDate = NSDate(timeIntervalSince1970: 1)

    dynamic var manifestVersion: String = ""

    dynamic var manifest: NSData = NSData()

    dynamic var storage: String = ""

    dynamic var archiveFormat: String = ""

    dynamic var releasedAt: Int64 = 0

    dynamic var languages: String = ""

    public override class func primaryKey() -> String? {
        return "gameId"
    }

    public static func fromGame(game: Game) -> GameCache? {
        if let gm = game.gameManifest {
            let cache = GameCache()
            cache.gameId = game.id
            cache.productionVersion = game.productionVersion
            cache.latestVersion = game.latestVersion
            cache.latestState = game.latestState.rawValue
            cache.manifest = gm.manifest.data()!
            cache.manifestVersion = gm.version
            cache.storage = gm.storage
            cache.archiveFormat = gm.archiveFormat
            cache.releasedAt = game.releasedAt
            cache.languages = game.languages.joinWithSeparator(",")
            if let fa = game.fetchedAt {
                cache.fetchedAt = fa
            } else {
                cache.fetchedAt = NSDate()
            }
            return cache
        } else {
            return nil
        }
    }

    public func getGame() -> Game! {
        do {
            let manifest: OTSGameManifest = try OTSGameManifest(data: self.manifest)
            return Game(cache: self, manifest: manifest)
        } catch {
            Log.error("failed to parse cache manifest data:\(error)")
            return nil
        }
    }
}

final class OtsimoCache: CacheProtocol {
    static let catalogKey = "catalog"
    static let sessionKey = "session"
    static let gameTTL: Double = 3600 * 24 * 14

    // Game
    func fetchGame(id: String, handler: (game: Game?, isExpired: Bool) -> Void) {
        let cached = store.objects(GameCache).filter(NSPredicate(format: "gameId = %@", id)).first
        if let gc = cached {
            let now: Double = NSDate().timeIntervalSince1970
            let fetched = gc.fetchedAt.timeIntervalSince1970
            if (now - fetched) > OtsimoCache.gameTTL {
                handler(game: gc.getGame(), isExpired: true)
            } else {
                handler(game: gc.getGame(), isExpired: false)
            }
        } else {
            handler(game: nil, isExpired: true)
        }
    }

    func cacheGame(game: Game) {
        do {
            if let gc = GameCache.fromGame(game) {
                try store.write {
                    store.add(gc, update: true)
                }
            } else {
                Log.error("failed to create GameCache object")
            }
        } catch let error {
            Log.error("failed to cache game \(error)")
        }
    }

// Catalog
    func fetchCatalog(handler: (OTSCatalog?) -> Void) {
        let c = store.objects(CatalogCache).first

        if let cat = c?.getCatalog() {
            handler(cat)
        } else {
            handler(nil)
        }
        /*
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
         })*/
    }
    func cacheCatalog(catalog: OTSCatalog) {
        let cc = CatalogCache()
        cc.id = OtsimoCache.catalogKey
        if let d = catalog.data() {
            cc.data = d
        } else {
            return
        }

        do {
            let localStore = try Realm()
            try localStore.write {
                localStore.add(cc, update: true)
            }
        } catch let error {
            Log.error("failed to cache catalog \(error)")
        }
    }

// Session
    func fetchSession() -> SessionCache? {
        let s = try! Realm()
        return s.objects(SessionCache).first
    }

    func cacheSession(session: SessionCache) {
        do {
            let s = try! Realm()
            try s.write {
                s.add(session, update: true)
            }
        } catch let error {
            Log.error("failed to cache session \(error)")
        }
    }

    func clearSession() {
        do {
            let objs = store.objects(SessionCache)
            try store.write {
                store.delete(objs)
            }
        } catch let error {
            Log.error("failed to clear session \(error)")
        }
    }
}
