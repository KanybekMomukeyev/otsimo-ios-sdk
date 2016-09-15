//
//  Otsimo+Utils.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 12/04/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation

class Template {

    class func render(_ str: String, dict: Dictionary<String, String>) -> String {
        var str = str
        for (key, value) in dict {
            str = str.replacingOccurrences(of: "{{.\(key)}}", with: value)
        }
        return str
    }
}

extension Otsimo {
    public var gamesDir: String {
        let root = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let libraryDirectoryPath: String = root[0]
        return libraryDirectoryPath + "/Games"
    }

    internal func isLocallyAvailable(_ gameID: String, version: String) -> Bool {
        let path = gamesDir + "/\(gameID)/\(version)/otsimo.json"
        return FileManager.default.fileExists(atPath: path)
    }

    public func fixGameAssetUrl(_ id: String, version: String, rawUrl: String, nolocal: Bool = false) -> String {
        if !nolocal && isLocallyAvailable(id, version: version) {
            return gamesDir + "/\(id)/\(version)/\(rawUrl)"
        } else {
            var u = cluster.diskStorageUrl()
            let v = versionToUrl(version)
            let dict: Dictionary<String, String> = [
                "id": id,
                "version": v
            ]
            if !rawUrl.isEmpty {
                if u.hasSuffix("/") && rawUrl.hasPrefix("/") {
                    u = "\(u)\(rawUrl.substring(from: rawUrl.characters.index(rawUrl.startIndex, offsetBy: 1)))"
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
