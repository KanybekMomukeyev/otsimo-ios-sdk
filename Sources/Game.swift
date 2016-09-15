//
//  Game.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 25/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import OtsimoApiGrpc

open class Game {
    open let id: String
    open var uniqueName: String = ""
    open var productionVersion: String = ""
    internal var latestVersion: String = ""
    internal var latestState: OTSReleaseState = OTSReleaseState.created
    internal var fetchedAt: Date?
    internal var storage: String = ""
    internal var archiveFormat: String = ""
    internal var releasedAt: Int64 = 0
    internal var languages: [String] = []
    internal var gameManifest: GameManifest? {
        didSet {
            fetchedAt = Date()
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
        releasedAt = listItem.releasedAt
        for i in listItem.languagesArray as AnyObject as! [NSString] {
            languages.append(i as String)
        }
    }

    public convenience init(gameRelease: OTSGameRelease) {
        self.init(gameId: gameRelease.gameId)
        if (gameRelease.releaseState == OTSReleaseState.production) {
            productionVersion = gameRelease.version
        }
        latestVersion = gameRelease.version
        latestState = gameRelease.releaseState
        storage = gameRelease.storage
        archiveFormat = gameRelease.archiveFormat
        releasedAt = gameRelease.releasedAt
        if gameRelease.hasGameManifest {
            uniqueName = gameRelease.gameManifest.uniqueName
            gameManifest = GameManifest(id: id, gameRelease: gameRelease)
            for i in gameRelease.gameManifest.languagesArray as AnyObject as! [NSString] {
                languages.append(i as String)
            }
        }
    }

    internal convenience init(cache: GameCache, manifest: OTSGameManifest) {
        self.init(gameId: cache.gameId)
        fetchedAt = cache.fetchedAt as Date
        uniqueName = manifest.uniqueName
        latestVersion = cache.latestVersion
        productionVersion = cache.productionVersion
        storage = cache.storage
        archiveFormat = cache.archiveFormat
        releasedAt = cache.releasedAt
        for i in manifest.languagesArray as AnyObject as! [NSString] {
            languages.append(i as String)
        }
        latestState = OTSReleaseState(rawValue: cache.latestState)!
        gameManifest = GameManifest(id: id, version: cache.manifestVersion, storage: cache.storage, archive: cache.archiveFormat, gameManifest: manifest)
    }

    open func getManifest(_ handler: @escaping (GameManifest?, OtsimoError) -> Void) {
        if let gm = gameManifest {
            Log.debug("Manifest already fetched for \(id), using it")
            // TODO(sercand) there could be a bug if previously get dev release and now want to production
            handler(gm, OtsimoError.none)
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
                        handler(self.gameManifest, .none)
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
                        handler(self.gameManifest, .none)
                    } else {
                        Log.error("failed to get getManifest \(err)")
                        handler(nil, err)
                    }
                }
            }
        }
    }

    open func cache() {
        assert(id != "", "id is empty")
        Otsimo.sharedInstance.cache.cacheGame(self)
    }

    open func defaultSettings() -> Data {
        return Data()
    }
}
