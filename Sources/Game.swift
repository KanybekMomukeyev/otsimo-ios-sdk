//
//  Game.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 25/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation

open class Game {
    open let id: String
    open var uniqueName: String = ""
    open var productionVersion: String = ""
    internal var latestVersion: String = ""
    internal var latestState = Apipb_ReleaseState.created
    internal var fetchedAt: Date?
    internal var storage: String = ""
    internal var archiveFormat: String = ""
    internal var releasedAt: Int64 = 0
    internal var languages: [String] = []
    public var gameManifest: GameManifest? {
        didSet {
            fetchedAt = Date()
        }
    }

    public init(gameId: String) {
        assert(gameId != "", "id is empty")
        self.id = gameId
    }

    public convenience init(gameRelease: Apipb_GameRelease) {
        self.init(gameId: gameRelease.gameId)
        if (gameRelease.releaseState == Apipb_ReleaseState.production) {
            productionVersion = gameRelease.version
        }
        latestVersion = gameRelease.version
        latestState = gameRelease.releaseState
        storage = gameRelease.storage
        archiveFormat = gameRelease.archiveFormat
        releasedAt = gameRelease.releasedAt
        uniqueName = gameRelease.gameManifest.uniqueName
        languages = gameRelease.gameManifest.languages
        gameManifest = GameManifest(id: id, gameRelease: gameRelease)
    }

    internal convenience init(cache: GameCache, manifest: Apipb_GameManifest) {
        self.init(gameId: cache.gameId)
        fetchedAt = cache.fetchedAt as Date
        uniqueName = manifest.uniqueName
        latestVersion = cache.latestVersion
        productionVersion = cache.productionVersion
        storage = cache.storage
        archiveFormat = cache.archiveFormat
        releasedAt = cache.releasedAt
        languages = manifest.languages
        latestState = Apipb_ReleaseState(rawValue: Int(cache.latestState))!
        gameManifest = GameManifest(id: id, version: cache.manifestVersion, storage: cache.storage, archive: cache.archiveFormat, gameManifest: manifest)
    }

    open var gameRelease: Apipb_GameRelease {
        var release = Apipb_GameRelease()
        release.gameId = id
        release.version = latestVersion
        release.releaseState = latestState
        release.storage = storage
        release.archiveFormat = archiveFormat
        release.gameManifest = gameManifest!.manifest
        release.releasedAt = releasedAt
        return release
    }

    open func cache() {
        assert(id != "", "id is empty")
        Otsimo.sharedInstance.cache.cacheGame(self)
    }

    open func defaultSettings() -> Data {
        return Data()
    }
}
