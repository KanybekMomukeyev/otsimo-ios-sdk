//
//  GameManifest.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 02/02/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import OtsimoApiGrpc

public class GameManifest {
    public let gameId: String
    public let version: String
    public let manifest: OTSGameManifest
    public let metadatas: [OTSGameMetadata]
    public let storage: String
    public let archiveFormat: String
    private var settings: GameSettings?
    private var keyvalue: GameKeyValueStore?

    init(id: String, gameRelease: OTSGameRelease) {
        gameId = id
        manifest = gameRelease.gameManifest
        metadatas = manifest.metadataArray as AnyObject as! [OTSGameMetadata]
        version = gameRelease.version
        settings = nil
        storage = gameRelease.storage
        archiveFormat = gameRelease.archiveFormat
    }

    init(id: String, version: String, storage: String, archive: String, gameManifest: OTSGameManifest) {
        gameId = id
        manifest = gameManifest
        metadatas = manifest.metadataArray as AnyObject as! [OTSGameMetadata]
        self.version = version
        settings = nil
        self.storage = storage
        archiveFormat = archive
    }

    public var localMetadata: OTSGameMetadata {
        get {
            if let lang = Otsimo.sharedInstance.preferredLanguage {
                for md in metadatas {
                    if md.language == lang {
                        return md
                    }
                }
            } else {

                for l in Otsimo.sharedInstance.languages {
                    for md in metadatas {
                        if md.language == l {
                            return md
                        }
                    }
                }
            }
            return defaultMetadata
        }
    }

    public var defaultMetadata: OTSGameMetadata {
        get {
            for md in metadatas {
                if md.language == manifest.defaultLanguage {
                    return md
                }
            }
            return metadatas[0]
        }
    }

    public var localVisibleName: String {
        get {
            return localMetadata.visibleName
        }
    }

    public var localIcon: String {
        get {
            return Otsimo.sharedInstance.fixGameAssetUrl(gameId, version: version, rawUrl: localMetadata.icon)
        }
    }

    public var localLogo: String {
        get {
            return Otsimo.sharedInstance.fixGameAssetUrl(gameId, version: version, rawUrl: localMetadata.logo)
        }
    }

    public var localSummary: String {
        get {
            return localMetadata.summary
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

    public var localPackage: String {
        get {
            for l in Otsimo.sharedInstance.languages {
                for md in metadatas {
                    if md.language == l {
                        return Otsimo.sharedInstance.fixGameAssetUrl(gameId, version: version, rawUrl: "package_\(l).\(archiveFormat)", nolocal: true)
                    }
                }
            }
            return globalPackage
        }
    }

    public var globalPackage: String {
        get {
            return Otsimo.sharedInstance.fixGameAssetUrl(gameId, version: version, rawUrl: "package.\(archiveFormat)", nolocal: true)
        }
    }

    public var remoteUrl: String {
        get {
            return Otsimo.sharedInstance.fixGameAssetUrl(gameId, version: version, rawUrl: manifest.main, nolocal: true)
        }
    }

    public var localSlug: String {
        get {
            return localMetadata.infoSlug
        }
    }

    public var localImages: [String] {
        get {
            var images: [String] = []
            let md = localMetadata
            for i in md.imagesArray {
                if let im = i as? String {
                    let u = Otsimo.sharedInstance.fixGameAssetUrl(gameId, version: version, rawUrl: im)
                    images.append(u)
                }
            }
            return images
        }
    }

    public func getSettings(handler: (GameSettings?) -> Void) {
        if let s = settings {
            handler(s)
        } else {
            GameSettings.fromIdAndVersion(self.gameId, version: self.version, path: self.manifest.settings) { gs in
                self.settings = gs
                handler(gs)
            }
        }
    }

    public func getKeyValueStore(handler: (GameKeyValueStore?) -> Void) {
        if let k = keyvalue {
            handler(k)
        } else {
            let suplangs = manifest.languagesArray as AnyObject as! [NSString]
            if suplangs.count == 0 {
                handler(nil)
                return
            }
            var lang: String = ""
            for syslang in Otsimo.sharedInstance.languages {
                if suplangs.contains(syslang) {
                    lang = syslang
                    break
                }
            }
            if lang == "" {
                lang = "general"
            }
            let rawUrl = "\(manifest.kvPath)/\(lang).json"

            GameKeyValueStore.fromIdAndVersion(gameId, version: version, language: lang, path: rawUrl) { k in
                self.keyvalue = k
                handler(k)
            }
        }
    }
}
