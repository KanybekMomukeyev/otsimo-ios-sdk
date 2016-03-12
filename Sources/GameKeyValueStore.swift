//
//  GameKeyValue.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 05/02/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation

public class GameKeyValueStore {
    public let store: [String: AnyObject]

    public init(dict: [String: AnyObject]) {
        self.store = dict
    }

    public func any(key: String) -> AnyObject? {
        return store[key]
    }

    public func string(key: String) -> String? {
        return store[key] as? String
    }

    public func string(key: String, defaultValue: String) -> String {
        if let v = store[key] as? String {
            return v
        }
        return defaultValue
    }

    public func integer(key: String) -> Int? {
        return store[key] as? Int
    }

    public func integer(key: String, defaultValue: Int) -> Int {
        if let v = store[key] as? Int {
            return v
        }
        return defaultValue
    }

    public func float(key: String) -> Float? {
        return store[key] as? Float
    }

    public func float(key: String, defaultValue: Float) -> Float {
        if let v = store[key] as? Float {
            return v
        }
        return defaultValue
    }

    public func boolean(key: String) -> Bool? {
        return store[key] as? Bool
    }

    public func boolean(key: String, defaultValue: Bool) -> Bool {
        if let v = store[key] as? Bool {
            return v
        }
        return defaultValue
    }

    public func settingsTitle(key: String) -> String? {
        return string("settings/\(key)/title")
    }

    public func settingsDescription(key: String) -> String? {
        return string("settings/\(key)/description")
    }

    public func settingsTitle(key: String, enumKey: String) -> String? {
        return string("settings/\(key)/keys/\(enumKey)/title")
    }

    public func settingsDescription(key: String, enumKey: String) -> String? {
        return string("settings/\(key)/keys/\(enumKey)/description")
    }

    internal static func fromData(data: NSData) -> GameKeyValueStore? {
        do {
            let object = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
            switch (object) {
            case let dictionary as [String: AnyObject]:
                return GameKeyValueStore(dict: dictionary)
            case _ as [AnyObject]:
                Log.error("wrong json format for keyvalue store")
            default:
                Log.error("failed to read parse JSON data, error= 'it is unknown formatted'")
            }
            return nil
        } catch(let error) {
            Log.error("failed to read parse JSON data, error=\(error)")
            return nil
        }
    }

    public static func fromIdAndVersion(gameID: String, version: String, language: String, path: String, handler: (GameKeyValueStore?) -> Void) {

        let id = KeyValueStoreCache.createID(gameID, version: version, language: language)
        if let sc = KeyValueStoreCache.storage.filter("id = %@", id).first {
            handler(sc.keyvalueStore())
            return
        }
        if Otsimo.sharedInstance.isLocallyAvailable(gameID, version: version) {
            let filepath = Otsimo.sharedInstance.fixGameAssetUrl(gameID, version: version, rawUrl: path)
            GameKeyValueStore.fromFile(filepath) {
                if let gs = $0 {
                    let sc = KeyValueStoreCache()
                    sc.id = id
                    sc.data = $1
                    sc.save()
                    handler(gs)
                } else {
                    handler(nil)
                }
            }
        } else {
            let url = Otsimo.sharedInstance.fixGameAssetUrl(gameID, version: version, rawUrl: path, nolocal: true)
            GameKeyValueStore.fromUrl(url) {
                if let gs = $0 {
                    let sc = KeyValueStoreCache()
                    sc.id = id
                    sc.data = $1
                    sc.save()
                    handler(gs)
                } else {
                    handler(nil)
                }
            }
        }
    }

    private static func fromFile(filepath: String, handler: (GameKeyValueStore?, NSData) -> Void) {
        let man = NSFileManager.defaultManager()
        if man.fileExistsAtPath(filepath) {
            if let data = man.contentsAtPath(filepath) {
                let kv = GameKeyValueStore.fromData(data)
                handler(kv, data)
            } else {
                Log.error("reding KeyValueStore at path \(filepath) failed")
                handler(nil, NSData())
            }
        } else {
            Log.error("settings at path \(filepath) does not exist")
            handler(nil, NSData())
        }
    }

    private static func fromUrl(url: String, handler: (GameKeyValueStore?, NSData) -> Void) {
        NetworkFetcher.get(url) { (data: NSData, error: OtsimoError) in
            switch (error) {
            case .None:
                let kv = GameKeyValueStore.fromData(data)
                handler(kv, data)
            default:
                Log.error("failed to fetch GameKeyValueStore \(error)")
                handler(nil, NSData())
            }
        }
    }
}