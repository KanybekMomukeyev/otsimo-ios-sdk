//
//  Otsimo+Utils.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 12/04/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation

extension Otsimo {
    public var gamesDir: String {
        let root = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let libraryDirectoryPath: String = root[0]
        return libraryDirectoryPath.stringByAppendingString("/Games")
    }

    internal func isLocallyAvailable(gameID: String, version: String) -> Bool {
        let path = gamesDir.stringByAppendingString("/\(gameID)/\(version)/otsimo.json")
        return NSFileManager.defaultManager().fileExistsAtPath(path)
    }

    public func fixGameAssetUrl(id: String, version: String, rawUrl: String, nolocal: Bool = false) -> String {
        if !nolocal && isLocallyAvailable(id, version: version) {
            return gamesDir.stringByAppendingString("/\(id)/\(version)/\(rawUrl)")
        } else {
            let v = versionToUrl(version)
            return "\(connection!.config.publicContentUrl)/\(id)/\(v)/\(rawUrl)"
        }
    }
}