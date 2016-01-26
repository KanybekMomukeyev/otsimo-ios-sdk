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
    internal var gameManifest: GameManifest?
    
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
                        handler(self.gameManifest, .None)
                    } else {
                        Log.error("failed to get getManifest \(err)")
                        handler(nil, err)
                    }
                }
            }
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
        self.manifest = gameRelease.gameManifest
        metadatas = manifest.metadataArray as AnyObject as! [OTSGameMetadata]
        version = gameRelease.version
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
            for l in Otsimo.sharedInstance.languages {
                for md in metadatas {
                    if md.language == l {
                        return md.imagesArray as AnyObject as![String]
                    }
                }
            }
            return manifest.defaultImagesArray as AnyObject as![String]
        }
    }
}

extension OTSCatalogItem {
    public func getGame() -> Game {
        return Game(gameId: self.gameId)
    }
}

