//
//  Otsimo+Utils.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 12/04/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation

class Template {

    class func render(str: String, dict: Dictionary<String, String>) -> String {
        var str = str
        for (key, value) in dict {
            str = str.stringByReplacingOccurrencesOfString("{{.\(key)}}", withString: value)
        }
        return str
    }
}

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
            var u = cluster.diskStorageUrl()
            let v = versionToUrl(version)
            let dict: Dictionary<String, String> = [
                "id": id,
                "version": v
            ]
            if !rawUrl.isEmpty {
                if u.hasSuffix("/") && rawUrl.hasPrefix("/") {
                    u = "\(u)\(rawUrl.substringFromIndex(rawUrl.startIndex.advancedBy(1)))"
                } else if !u.hasSuffix("/") && rawUrl.hasPrefix("/") {
                    u = "\(u)\(rawUrl)"
                } else if u.hasSuffix("/") && !rawUrl.hasPrefix("/") {
                    u = "\(u)\(rawUrl)"
                } else {
                    u = "\(u)/\(rawUrl)"
                }
            }
            return Template.render(u, dict: dict)
        }
    }
}