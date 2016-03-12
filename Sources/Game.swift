//
//  Game.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 25/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import OtsimoApiGrpc

public class Game {
    public let id: String
    public var uniqueName: String = ""
    public var productionVersion: String = ""
    internal var latestVersion: String = ""
    internal var latestState: OTSReleaseState = OTSReleaseState.Created
    internal var fetchedAt: NSDate?
    internal var storage: String = ""
    internal var archiveFormat: String = ""
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
        storage = listItem.storage
        archiveFormat = listItem.archiveFormat
    }

    public convenience init(gameRelease: OTSGameRelease) {
        self.init(gameId: gameRelease.gameId)
        if (gameRelease.releaseState == OTSReleaseState.Production) {
            productionVersion = gameRelease.version
        }
        latestVersion = gameRelease.version
        latestState = gameRelease.releaseState
        storage = gameRelease.storage
        archiveFormat = gameRelease.archiveFormat

        if gameRelease.hasGameManifest {
            uniqueName = gameRelease.gameManifest.uniqueName
            gameManifest = GameManifest(id: id, gameRelease: gameRelease)
        }
    }

    internal convenience init(cache: GameCache, manifest: OTSGameManifest) {
        self.init(gameId: cache.gameId)
        fetchedAt = cache.fetchedAt
        uniqueName = manifest.uniqueName
        latestVersion = cache.latestVersion
        productionVersion = cache.productionVersion
        storage = cache.storage
        archiveFormat = cache.archiveFormat

        latestState = OTSReleaseState(rawValue: cache.latestState)!
        gameManifest = GameManifest(id: id, version: cache.manifestVersion, storage: cache.storage, archive: cache.archiveFormat, gameManifest: manifest)
    }

    public func getManifest(handler: (GameManifest?, OtsimoError) -> Void) {
        if let gm = gameManifest {
            Log.debug("Manifest already fetched for \(id), using it")
            // TODO(sercand) there could be a bug if previously get dev release and now want to production
            handler(gm, OtsimoError.None)
        } else {
            if Otsimo.sharedInstance.onlyProduction {
                Log.debug("Game:getManifest-> going to fetch game='\(id)' version='\(productionVersion)' as production version")
                Otsimo.sharedInstance.getGameRelease(id, version: productionVersion, onlyProduction: true) { resp, err in
                    if let r = resp {
                        self.gameManifest = GameManifest(id: self.id, gameRelease: r)
                        self.productionVersion = r.version
                        self.storage = r.storage
                        self.archiveFormat = r.archiveFormat
                        self.cache()
                        handler(self.gameManifest, .None)
                    } else {
                        Log.error("failed to get getManifest \(err)")
                        handler(nil, err)
                    }
                }
            } else {
                Log.debug("Game:getManifest-> going to fetch game='\(id)' version='\(latestVersion)' as latestVersion version")
                Otsimo.sharedInstance.getGameRelease(id, version: latestVersion, onlyProduction: false) { resp, err in
                    if let r = resp {
                        self.gameManifest = GameManifest(id: self.id, gameRelease: r)
                        self.productionVersion = r.version
                        self.storage = r.storage
                        self.archiveFormat = r.archiveFormat
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

extension OTSCatalogItem {
    public func getGame() -> Game {
        return Game(gameId: self.gameId)
    }
}
