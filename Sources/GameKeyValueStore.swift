//
//  GameKeyValue.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 05/02/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import Haneke

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
    
    public static func fromUrl(url: NSURL, handler: (GameKeyValueStore?, OtsimoError) -> Void) {
        let cache = Shared.JSONCache
        cache.fetch(URL: url).onSuccess {j in
            handler(GameKeyValueStore(dict: j.dictionary), OtsimoError.None)
        }.onFailure {e in
            handler(nil, OtsimoError.ServiceError(message: "failed to fetch data: \(e)"))
        }
    }
}