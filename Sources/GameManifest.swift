//
//  GameManifest.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 02/02/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import OtsimoApiGrpc
import Haneke

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
