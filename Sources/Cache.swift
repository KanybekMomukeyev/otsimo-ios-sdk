//
//  Cache.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 28/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import RealmSwift

let store = try! Realm()

class CatalogCache: Object {
    dynamic var id: String = "catalog"
    dynamic var data = Data()
    override class func primaryKey() -> String? {
        return "id"
    }

    func getCatalog() -> Apipb_Catalog? {
        do {
            return try Apipb_Catalog(protobuf: data)
        } catch (let error){
            Log.error("failed to parse catalog:\(error)")
            return nil
        }
    }
}

open class SettingsCache: Object {
    open dynamic var id: String = ""
    open dynamic var data: Data = Data()

    override open class func primaryKey() -> String? {
        return "id"
    }

    static var storage: Results<SettingsCache> {
        let s = try! Realm()
        return s.objects(SettingsCache.self)
    }

    open func gameSettings() -> GameSettings? {
        return GameSettings.fromData(data)
    }

    static func settings(id:String) -> SettingsCache? {
        let s = try! Realm()
        return s.object(ofType: SettingsCache.self, forPrimaryKey: id)
    }
    
    open func save() {
        do {
            let s = try Realm()
            try s.write {
                s.add(self, update: true)
            }
        } catch(let error) {
            Log.error("failed to store,err=\(error)")
        }
    }

    static func createID(_ gameid: String, version: String) -> String {
        return "\(gameid)_\(version)"
    }
}

open class KeyValueStoreCache: Object {
    open dynamic var id: String = ""
    open dynamic var data: Data = Data()

    override open class func primaryKey() -> String? {
        return "id"
    }

    static var storage: Results<KeyValueStoreCache> {
        let s = try! Realm();
        return s.objects(KeyValueStoreCache.self)
    }

    static func object(id:String) -> KeyValueStoreCache? {
        let s = try! Realm();
        return s.object(ofType: KeyValueStoreCache.self, forPrimaryKey: id)
    }
    
    open func keyvalueStore() -> GameKeyValueStore? {
        return GameKeyValueStore.fromData(data)
    }

    open func save() {
        do {
            let s = try Realm();
            try s.write {
                s.add(self, update: true)
            }
        } catch(let error) {
            Log.error("failed to store,err=\(error)")
        }
    }

    static func createID(_ gameid: String, version: String, language: String) -> String {
        return "\(gameid)_\(version)_\(language)"
    }
}

@available( *, deprecated : 1.1)
open class SessionCache: Object {
    dynamic var id: String = "session"
    dynamic var profileId: String = ""
    dynamic var email: String = ""
    open override class func primaryKey() -> String? {
        return "id"
    }
}

open class GameCache: Object {
    dynamic var gameId: String = ""

    dynamic var productionVersion: String = ""

    dynamic var latestVersion: String = ""

    dynamic var latestState: Int32 = 0

    dynamic var fetchedAt: Date = Date(timeIntervalSince1970: 1)

    dynamic var manifestVersion: String = ""

    dynamic var manifest: Data = Data()

    dynamic var storage: String = ""

    dynamic var archiveFormat: String = ""

    dynamic var releasedAt: Int64 = 0

    dynamic var languages: String = ""

    open override class func primaryKey() -> String? {
        return "gameId"
    }

    open static func fromGame(_ game: Game) -> GameCache? {
        if let gm = game.gameManifest {
            let cache = GameCache()
            cache.gameId = game.id
            cache.productionVersion = game.productionVersion
            cache.latestVersion = game.latestVersion
            cache.latestState = Int32(game.latestState.rawValue)
            cache.manifest = try! gm.manifest.serializeProtobuf()
            cache.manifestVersion = gm.version
            cache.storage = gm.storage
            cache.archiveFormat = gm.archiveFormat
            cache.releasedAt = game.releasedAt
            cache.languages = game.languages.joined(separator: ",")
            if let fa = game.fetchedAt {
                cache.fetchedAt = fa as Date
            } else {
                cache.fetchedAt = Date()
            }
            return cache
        } else {
            return nil
        }
    }

    open func getGame() -> Game! {
        do {
            let manifest: Apipb_GameManifest = try Apipb_GameManifest(protobuf: self.manifest)
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
    func fetchGame(_ id: String, handler: (_ game: Game?, _ isExpired: Bool) -> Void) {
        let s = try! Realm()
        if let gc = s.object(ofType: GameCache.self, forPrimaryKey: id) {
            let now: Double = Date().timeIntervalSince1970
            let fetched = gc.fetchedAt.timeIntervalSince1970
            if (now - fetched) > OtsimoCache.gameTTL {
                handler(gc.getGame(), true)
            } else {
                handler(gc.getGame(), false)
            }
        } else {
            handler(nil, true)
        }
    }

    func cacheGame(_ game: Game) {
        do {
            let s = try Realm()
            if let gc = GameCache.fromGame(game) {
                try s.write {
                    s.add(gc, update: true)
                }
            } else {
                Log.error("failed to create GameCache object")
            }
        } catch let error {
            Log.error("failed to cache game \(error)")
        }
    }
    
    func allCachedGames() -> [Game]{
        let s = try! Realm()
        var games : [Game] = []
        for gc in s.objects(GameCache.self){
            games.append(gc.getGame())
        }
        return games
    }


// Catalog
    func fetchCatalog(_ handler: (Apipb_Catalog?) -> Void) {
        let c = store.objects(CatalogCache.self).first

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
    func cacheCatalog(_ catalog: Apipb_Catalog) {
        let cc = CatalogCache()
        cc.id = OtsimoCache.catalogKey
        do{
            cc.data = try catalog.serializeProtobuf()
        }catch{
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
        return s.objects(SessionCache.self).first
    }

    func cacheSession(_ session: SessionCache) {
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
            let objs = store.objects(SessionCache.self)
            try store.write {
                store.delete(objs)
            }
        } catch let error {
            Log.error("failed to clear session \(error)")
        }
    }
}
