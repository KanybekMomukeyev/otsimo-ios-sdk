//
//  GameSettings.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 03/02/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import OtsimoApiGrpc
import RealmSwift

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
        let id = SettingsCache.createID(gameID, version: version)
        if let sc = SettingsCache.storage.filter("id = %@", id).first {
            handler(sc.gameSettings())
            return
        }
        if Otsimo.sharedInstance.isLocallyAvailable(gameID, version: version) {
            let filepath = Otsimo.sharedInstance.fixGameAssetUrl(gameID, version: version, rawUrl: path)
            GameSettings.fromFile(filepath) {
                if let gs = $0 {
                    let sc = SettingsCache()
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
            GameSettings.fromUrl(url) {
                if let gs = $0 {
                    let sc = SettingsCache()
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

    internal static func fromData(data: NSData) -> GameSettings? {
        do {
            let object = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
            switch (object) {
            case let dictionary as [String: AnyObject]:
                let gs = GameSettings()
                gs.readDictionary(dictionary)
                return gs
            case _ as [AnyObject]:
                Log.error("wrong json format for settings")
            default:
                Log.error("failed to read parse JSON settings, error= 'it is unknown formatted'")
            }
            return nil
        } catch(let error) {
            Log.error("failed to read parse JSON settings, error=\(error)")
            return nil
        }
    }

    private func readDictionary(dict: [String: AnyObject]) -> Bool {
        if let prop = dict["properties"] as? [String: [String: AnyObject]] {
            for (k, v) in prop {
                addProperty(k, prop: v)
            }
            return true
        } else {
            Log.error("missing properties object")
            return false
        }
    }

    private static func fromFile(filepath: String, handler: (GameSettings?, NSData) -> Void) {
        let man = NSFileManager.defaultManager()
        if man.fileExistsAtPath(filepath) {
            if let data = man.contentsAtPath(filepath) {
                let gs = GameSettings.fromData(data)
                handler(gs, data)
            } else {
                Log.error("reding settings at path \(filepath) failed")
                handler(nil, NSData())
            }
        } else {
            Log.error("settings at path \(filepath) does not exist")
            handler(nil, NSData())
        }
    }

    private static func fromUrl(url: String, handler: (GameSettings?, NSData) -> Void) {
        NetworkFetcher.get(url) { (data: NSData, error: OtsimoError) in
            switch (error) {
            case .None:
                let gs = GameSettings.fromData(data)
                handler(gs, data)
            default:
                Log.error("failed to fetch gamesettings \(error)")
                handler(nil, NSData())
            }
        }
    }

    private func addProperty(key: String, prop: [String: AnyObject]) {
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
