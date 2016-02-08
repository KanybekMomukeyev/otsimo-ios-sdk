//
//  Game.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 25/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import OtsimoApiGrpc
import Haneke

public class Game {
    public let id: String
    public var uniqueName: String = ""
    public var productionVersion: String = ""
    internal var latestVersion: String = ""
    internal var latestState: OTSReleaseState = OTSReleaseState.Created
    internal var fetchedAt: NSDate?
    
    internal var gameManifest: GameManifest? {
        didSet {
            fetchedAt = NSDate()
        }
    }
    
    public init(gameId: String) {
        assert(gameId != "", "id is empty")
        self.id = gameId
    }
    
    public convenience init(listItem: OTSListItem) {
        self.init(gameId: listItem.gameId)
        uniqueName = listItem.uniqueName
        productionVersion = listItem.productionVersion
        latestVersion = listItem.latestVersion
        latestState = listItem.latestState
    }
    
    public convenience init(gameRelease: OTSGameRelease) {
        self.init(gameId: gameRelease.gameId)
        if (gameRelease.releaseState == OTSReleaseState.Production) {
            productionVersion = gameRelease.version
        }
        latestVersion = gameRelease.version
        latestState = gameRelease.releaseState
        if gameRelease.hasGameManifest {
            uniqueName = gameRelease.gameManifest.uniqueName
            gameManifest = GameManifest(id: id, gameRelease: gameRelease)
        }
    }
    
    internal convenience init(cache: OTSGameCache, manifest: OTSGameManifest) {
        self.init(gameId: cache.gameId)
        fetchedAt = NSDate(timeIntervalSince1970: cache.fetchedAt)
        uniqueName = manifest.uniqueName
        latestVersion = cache.latestVersion
        productionVersion = cache.productionVersion
        latestState = cache.latestState
        gameManifest = GameManifest(id: id, version: cache.manifestVersion, gameManifest: manifest)
    }
    
    public func getManifest(handler: (GameManifest?, OtsimoError) -> Void) {
        if let gm = gameManifest {
            // TODO(sercand) there could be a bug if previously get dev release and now want to production
            handler(gm, OtsimoError.None)
        } else {
            if Otsimo.sharedInstance.useProductionGames {
                Otsimo.sharedInstance.getGameRelease(id, version: productionVersion, onlyProduction: true) {resp, err in
                    if let r = resp {
                        self.gameManifest = GameManifest(id: self.id, gameRelease: r)
                        self.productionVersion = r.version
                        self.cache()
                        handler(self.gameManifest, .None)
                    } else {
                        Log.error("failed to get getManifest \(err)")
                        handler(nil, err)
                    }
                }
            } else {
                Otsimo.sharedInstance.getGameRelease(id, version: latestVersion, onlyProduction: false) {resp, err in
                    if let r = resp {
                        self.gameManifest = GameManifest(id: self.id, gameRelease: r)
                        self.productionVersion = r.version
                        self.cache()
                        handler(self.gameManifest, .None)
                    } else {
                        Log.error("failed to get getManifest \(err)")
                        handler(nil, err)
                    }
                }
            }
        }
    }
    
    public func cache() {
        assert(id != "", "id is empty")
        Otsimo.sharedInstance.cache.cacheGame(self)
    }
    
    public func defaultSettings() -> NSData {
        return NSData()
    }
}

extension Game: DataConvertible, DataRepresentable {
    
    public typealias Result = Game
    
    public class func convertFromData(data: NSData) -> Result? {
        var error: NSError? = nil
        let cache: OTSGameCache = OTSGameCache(data: data, error: &error)
        if let theError = error {
            Log.error("failed to parse cache data:\(theError)")
            return nil
        } else {
            let manifest: OTSGameManifest = OTSGameManifest(data: cache.manifest, error: &error)
            if let te = error {
                Log.error("failed to parse cache manifest data:\(te)")
                return nil
            } else {
                return Game(cache: cache, manifest: manifest)
            }
        }
    }
    
    public func asData() -> NSData! {
        if let gm = gameManifest {
            let cache: OTSGameCache = OTSGameCache()
            cache.gameId = id
            cache.productionVersion = productionVersion
            cache.latestVersion = latestVersion
            cache.latestState = latestState
            cache.manifest = gm.manifest.data()
            cache.manifestVersion = gm.version
            if let fa = fetchedAt {
                cache.fetchedAt = fa.timeIntervalSince1970
            } else {
                cache.fetchedAt = NSDate().timeIntervalSince1970
            }
            return cache.data()
        } else {
            return nil
        }
    }
}

extension OTSCatalogItem {
    public func getGame() -> Game {
        return Game(gameId: self.gameId)
    }
}

