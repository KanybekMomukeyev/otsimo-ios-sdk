//
//  GameManifest.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 02/02/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation

open class GameManifest {
    open let gameId: String
    open let version: String
    open let manifest: Apipb_GameManifest
    open let metadatas: [Apipb_GameMetadata]
    open let storage: String
    open let archiveFormat: String
    fileprivate var settings: GameSettings?
    fileprivate var keyvalue: GameKeyValueStore?

    init(id: String, gameRelease: Apipb_GameRelease) {
        gameId = id
        manifest = gameRelease.gameManifest
        metadatas = manifest.metadata
        version = gameRelease.version
        settings = nil
        storage = gameRelease.storage
        archiveFormat = gameRelease.archiveFormat
    }

    init(id: String, version: String, storage: String, archive: String, gameManifest: Apipb_GameManifest) {
        gameId = id
        manifest = gameManifest
        metadatas = manifest.metadata
        self.version = version
        settings = nil
        self.storage = storage
        archiveFormat = archive
    }

    open var localMetadata: Apipb_GameMetadata {
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

    open var defaultMetadata: Apipb_GameMetadata {
        get {
            for md in metadatas {
                if md.language == manifest.defaultLanguage {
                    return md
                }
            }
            return metadatas[0]
        }
    }

    open var localVisibleName: String {
        get {
            return localMetadata.visibleName
        }
    }

    open var localIcon: String {
        get {
            return Otsimo.sharedInstance.fixGameAssetUrl(gameId, version: version, rawUrl: localMetadata.icon)
        }
    }

    open var localLogo: String {
        get {
            return Otsimo.sharedInstance.fixGameAssetUrl(gameId, version: version, rawUrl: localMetadata.logo)
        }
    }

    open var localSummary: String {
        get {
            return localMetadata.summary
        }
    }

    open var localDescription: String {
        get {
            return localMetadata.description_p
        }
    }

    open var localPackage: String {
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

    open var globalPackage: String {
        get {
            return Otsimo.sharedInstance.fixGameAssetUrl(gameId, version: version, rawUrl: "package.\(archiveFormat)", nolocal: true)
        }
    }

    open var remoteUrl: String {
        get {
            return Otsimo.sharedInstance.fixGameAssetUrl(gameId, version: version, rawUrl: manifest.main, nolocal: true)
        }
    }

    open var localSlug: String {
        get {
            return localMetadata.infoSlug
        }
    }

    open var localImages: [String] {
        get {
            var images: [String] = []
            let md = localMetadata
            for im in md.images{
                let u = Otsimo.sharedInstance.fixGameAssetUrl(gameId, version: version, rawUrl: im)
                images.append(u)
            }
            return images
        }
    }

    open func getSettings(_ handler: @escaping (GameSettings?) -> Void) {
        if let s = settings {
            handler(s)
        } else {
            GameSettings.fromIdAndVersion(self.gameId, version: self.version, path: self.manifest.settings) { gs in
                self.settings = gs
                handler(gs)
            }
        }
    }

    open func getKeyValueStore(_ handler: @escaping (GameKeyValueStore?) -> Void) {
        if let k = keyvalue {
            handler(k)
        } else {
            var lang: String = ""
            let suplangs = manifest.languages

            if let plang = Otsimo.sharedInstance.preferredLanguage {
                if suplangs.contains(plang) {
                    lang = plang
                }
            } else {
                for syslang in Otsimo.sharedInstance.languages {
                    if suplangs.contains(syslang) {
                        lang = syslang
                        break
                    }
                }
            }

            if lang == "" {
                lang = manifest.defaultLanguage
            }

            let rawUrl = "\(manifest.kvPath)/\(lang).json"

            GameKeyValueStore.fromIdAndVersion(gameId, version: version, language: lang, path: rawUrl) { k in
                self.keyvalue = k
                handler(k)
            }
        }
    }
}
