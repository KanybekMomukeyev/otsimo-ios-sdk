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

public class Game : DataConvertible, DataRepresentable {
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
        Otsimo.sharedInstance.cache.cacheGame(self)
    }
    
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

public class GameManifest {
    public let gameId: String
    public let manifest: OTSGameManifest
    public let metadatas: [OTSGameMetadata]
    public let version: String
    
    init(id: String, gameRelease: OTSGameRelease) {
        gameId = id
        manifest = gameRelease.gameManifest
        metadatas = manifest.metadataArray as AnyObject as! [OTSGameMetadata]
        version = gameRelease.version
    }
    
    init(id: String, version: String, gameManifest: OTSGameManifest) {
        gameId = id
        manifest = gameManifest
        metadatas = manifest.metadataArray as AnyObject as! [OTSGameMetadata]
        self.version = version
    }
    
    public var localVisibleName: String {
        get {
            for l in Otsimo.sharedInstance.languages {
                for md in metadatas {
                    if md.language == l {
                        return md.visibleName
                    }
                }
            }
            return manifest.defaultName
        }
    }
    
    public var localIcon: String {
        get {
            for l in Otsimo.sharedInstance.languages {
                for md in metadatas {
                    if md.language == l {
                        return Otsimo.sharedInstance.fixGameAssetUrl(gameId, version: version, rawUrl: md.icon)
                    }
                }
            }
            return Otsimo.sharedInstance.fixGameAssetUrl(gameId, version: version, rawUrl: manifest.defaultIcon)
        }
    }
    
    public var localLogo: String {
        get {
            for l in Otsimo.sharedInstance.languages {
                for md in metadatas {
                    if md.language == l {
                        return Otsimo.sharedInstance.fixGameAssetUrl(gameId, version: version, rawUrl: md.logo)
                    }
                }
            }
            return Otsimo.sharedInstance.fixGameAssetUrl(gameId, version: version, rawUrl: manifest.defaultLogo)
        }
    }
    
    public var localSummary: String {
        get {
            for l in Otsimo.sharedInstance.languages {
                for md in metadatas {
                    if md.language == l {
                        return md.summary
                    }
                }
            }
            return ""
        }
    }
    
    public var localDescription: String {
        get {
            for l in Otsimo.sharedInstance.languages {
                for md in metadatas {
                    if md.language == l {
                        return md.description_p
                    }
                }
            }
            return ""
        }
    }
    
    public var localImages: [String] {
        get {
            var images: [String] = []
            
            for l in Otsimo.sharedInstance.languages {
                for md in metadatas {
                    if md.language == l {
                        for i in md.imagesArray {
                            if let im = i as? String {
                                let u = Otsimo.sharedInstance.fixGameAssetUrl(gameId, version: version, rawUrl: im)
                                images.append(u)
                            }
                        }
                        return images;
                    }
                }
            }
            for i in manifest.defaultImagesArray {
                if let im = i as? String {
                    let u = Otsimo.sharedInstance.fixGameAssetUrl(gameId, version: version, rawUrl: im)
                    images.append(u)
                }
            }
            return images
        }
    }
}

extension OTSCatalogItem {
    public func getGame() -> Game {
        return Game(gameId: self.gameId)
    }
}

