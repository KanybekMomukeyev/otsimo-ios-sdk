//
//  GameSettings.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 03/02/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import Haneke
import OtsimoApiGrpc

public enum SettingsProperty {
    case Integer(key: String, defaultValue: Int)
    case Float(key: String, defaultValue: Float64)
    case Text(key: String, defaultValue: String)
    case Boolean(key: String, defaultValue: Bool)
    case Enum(key: String, defaultValue: String, values: [String])
    
    public var defaultValue: SettingsPropertyValue {
        get {
            switch (self) {
            case .Boolean(let key, let defaultValue):
                return SettingsPropertyValue.Boolean(key: key, value: defaultValue)
            case .Integer(let key, let defaultValue):
                return SettingsPropertyValue.Integer(key: key, value: defaultValue)
            case .Enum(let key, let defaultValue, _):
                return SettingsPropertyValue.Text(key: key, value: defaultValue)
            case .Text(let key, let defaultValue):
                return SettingsPropertyValue.Text(key: key, value: defaultValue)
            case .Float(let key, let defaultValue):
                return SettingsPropertyValue.Float(key: key, value: defaultValue)
            }
        }
    }
    
    public var key: String {
        get {
            switch (self) {
            case .Boolean(let key, _):
                return key
            case .Integer(let key, _):
                return key
            case .Enum(let key, _, _):
                return key
            case .Text(let key, _):
                return key
            case .Float(let key, _):
                return key
            }
        }
    }
}

public enum SettingsPropertyValue {
    case Integer(key: String, value: Int)
    case Float(key: String, value: Float64)
    case Text(key: String, value: String)
    case Boolean(key: String, value: Bool)
    
    public var value: AnyObject {
        get {
            switch (self) {
            case .Integer(_, let value):
                return value
            case .Boolean(_, let value):
                return value
            case .Text(_, let value):
                return value
            case .Float(_, let value):
                return value
            }
        }
    }
    
    public var integer: Int! {
        get {
            switch (self) {
            case .Integer(_, let value):
                return value
            default:
                return nil
            }
        }
    }
    public var string: String! {
        get {
            switch (self) {
            case .Text(_, let value):
                return value
            default:
                return nil
            }
        }
    }
    public var float: Float64! {
        get {
            switch (self) {
            case .Float(_, let value):
                return value
            default:
                return nil
            }
        }
    }
    public var boolean: Bool! {
        get {
            switch (self) {
            case .Boolean(_, let value):
                return value
            case .Integer(_, let value):
                return value != 0
            default:
                return nil
            }
        }
    }
    public var key: String {
        get {
            switch (self) {
            case .Integer(let key, _):
                return key
            case .Text(let key, _):
                return key
            case .Float(let key, _):
                return key
            case .Boolean(let key, _):
                return key
            }
        }
    }
}

public typealias SettingsValues = [String: SettingsPropertyValue]

public class GameSettings {
    public private(set) var properties: [SettingsProperty] = []
    
    public func getDefaultValues() -> SettingsValues {
        var v: SettingsValues = SettingsValues()
        for p in properties {
            v[p.key] = p.defaultValue
        }
        return v
    }
    
    
    public func getFromKey(key: String) -> SettingsProperty? {
        for p in properties {
            if p.key == key {
                return p
            }
        }
        return nil
    }
    
    public static func fromIdAndVersion(gameID: String, version: String, path: String, handler: (GameSettings?) -> Void) {
        let url = Otsimo.sharedInstance.fixGameAssetUrl(gameID, version: version, rawUrl: path)
        GameSettings.fromUrl(url, handler: handler)
    }
    
    private static func fromUrl(settingsUrl: String, handler: (GameSettings?) -> Void) {
        let cache = Shared.JSONCache
        let URL = NSURL(string: settingsUrl)
        
        Log.info("going to fetch \(settingsUrl)")
        
        if let url = URL {
            cache.fetch(URL: url).onSuccess {JSON in
                if let prop = JSON.dictionary?["properties"] as? [String : [String : AnyObject]] {
                    let gs: GameSettings = GameSettings()
                    for (k, v) in prop {
                        gs.addProperty(k, prop: v)
                    }
                    handler(gs)
                } else {
                    Log.error("missing properties object")
                    handler(nil)
                }
            }.onFailure {e in
                Log.error("failed to fetch gamesettings \(e)")
                handler(nil)
            }
        } else {
            Log.error("failed to init url '\(settingsUrl)'")
            handler(nil)
        }
    }
    
    private func addProperty(key: String, prop: [String: AnyObject]) {
        print(key, prop["id"]!)
        if let t = prop["type"] as? String {
            switch (t) {
            case "string":
                addStringProperty(key, prop: prop)
            case "integer":
                addIntegerProperty(key, prop: prop)
            case "boolean":
                addBooleanProperty(key, prop: prop)
            default:
                Log.error("unknown type \(t)")
            }
        }
    }
    
    private func addIntegerProperty(key: String, prop: [String: AnyObject]) {
        if let d = prop["default"] as? Int {
            properties.append(SettingsProperty.Integer(key: key, defaultValue: d))
        } else {
            Log.error("failed to get default value of \(key)")
        }
    }
    
    private func addBooleanProperty(key: String, prop: [String: AnyObject]) {
        if let d = prop["default"] as? Bool {
            properties.append(SettingsProperty.Boolean(key: key, defaultValue: d))
        } else {
            Log.error("failed to get default value of \(key)")
        }
    }
    
    private func addStringProperty(key: String, prop: [String: AnyObject]) {
        if let vs = prop["enum"] as? [String] {
            addEnumProperty(key, prop: prop, values: vs)
        } else if let d = prop["default"] as? String {
            properties.append(SettingsProperty.Text(key: key, defaultValue: d))
        } else {
            Log.error("failed to get default value of \(key)")
        }
    }
    
    private func addEnumProperty(key: String, prop: [String: AnyObject], values: [String]) {
        if let d = prop["default"] as? String {
            properties.append(SettingsProperty.Enum(key: key, defaultValue: d, values: values))
        } else {
            Log.error("failed to get default value of \(key)")
        }
    }
}

