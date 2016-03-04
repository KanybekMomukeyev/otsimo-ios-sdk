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

    public var localMetadata: OTSGameMetadata? {
        get {
            for l in Otsimo.sharedInstance.languages {
                for md in metadatas {
                    if md.language == l {
                        return md
                    }
                }
            }
            return nil
        }
    }

    public var localSlug: String {
        get {
            for l in Otsimo.sharedInstance.languages {
                for md in metadatas {
                    if md.language == l {
                        return md.infoSlug
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
            var rawUrl: String
            if lang == "" {
                rawUrl = "\(manifest.kvPath)/general.json"
            } else {
                rawUrl = "\(manifest.kvPath)/\(lang).json"
            }
            let fullUrl: String = Otsimo.sharedInstance.fixGameAssetUrl(self.gameId, version: self.version, rawUrl: rawUrl)
            let url = NSURL(string: fullUrl)!
            GameKeyValueStore.fromUrl(url) { kv, e in
                self.keyvalue = kv
                handler(self.keyvalue)
            }
        }
    }
}
