//
//  GameKeyValue.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 05/02/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation

open class GameKeyValueStore {
    open let store: [String: AnyObject]

    public init(dict: [String: AnyObject]) {
        self.store = dict
    }

    open func any(_ key: String) -> AnyObject? {
        return store[key]
    }

    open func string(_ key: String) -> String? {
        return store[key] as? String
    }

    open func string(_ key: String, defaultValue: String) -> String {
        if let v = store[key] as? String {
            return v
        }
        return defaultValue
    }

    open func integer(_ key: String) -> Int? {
        return store[key] as? Int
    }

    open func integer(_ key: String, defaultValue: Int) -> Int {
        if let v = store[key] as? Int {
            return v
        }
        return defaultValue
    }

    open func float(_ key: String) -> Float? {
        return store[key] as? Float
    }

    open func float(_ key: String, defaultValue: Float) -> Float {
        if let v = store[key] as? Float {
            return v
        }
        return defaultValue
    }

    open func boolean(_ key: String) -> Bool? {
        return store[key] as? Bool
    }

    open func boolean(_ key: String, defaultValue: Bool) -> Bool {
        if let v = store[key] as? Bool {
            return v
        }
        return defaultValue
    }

    open func settingsTitle(_ key: String) -> String? {
        return string("settings/\(key)/title")
    }

    open func settingsDescription(_ key: String) -> String? {
        return string("settings/\(key)/description")
    }

    open func settingsTitle(_ key: String, enumKey: String) -> String? {
        return string("settings/\(key)/keys/\(enumKey)/title")
    }

    open func settingsDescription(_ key: String, enumKey: String) -> String? {
        return string("settings/\(key)/keys/\(enumKey)/description")
    }

    internal static func fromData(_ data: Data) -> GameKeyValueStore? {
        do {
            let object = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
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

    open static func fromIdAndVersion(_ gameID: String, version: String, language: String, path: String, handler: @escaping (GameKeyValueStore?) -> Void) {

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

    fileprivate static func fromFile(_ filepath: String, handler: (GameKeyValueStore?, Data) -> Void) {
        let man = FileManager.default
        if man.fileExists(atPath: filepath) {
            if let data = man.contents(atPath: filepath) {
                let kv = GameKeyValueStore.fromData(data)
                handler(kv, data)
            } else {
                Log.error("reding KeyValueStore at path \(filepath) failed")
                handler(nil, Data())
            }
        } else {
            Log.error("settings at path \(filepath) does not exist")
            handler(nil, Data())
        }
    }

    fileprivate static func fromUrl(_ url: String, handler: @escaping (GameKeyValueStore?, Data) -> Void) {
        NetworkFetcher.get(url) { (data: Data, error: OtsimoError) in
            switch (error) {
            case .none:
                let kv = GameKeyValueStore.fromData(data)
                handler(kv, data)
            default:
                Log.error("failed to fetch GameKeyValueStore \(error)")
                handler(nil, Data())
            }
        }
    }
}
