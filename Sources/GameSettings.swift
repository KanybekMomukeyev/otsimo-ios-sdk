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
    case integer(key: String, defaultValue: Int)
    case float(key: String, defaultValue: Float64)
    case text(key: String, defaultValue: String)
    case boolean(key: String, defaultValue: Bool)
    case `enum`(key: String, defaultValue: String, values: [String])

    public var defaultValue: SettingsPropertyValue {
        get {
            switch (self) {
            case .boolean(let key, let defaultValue):
                return SettingsPropertyValue.Boolean(key: key, value: defaultValue)
            case .integer(let key, let defaultValue):
                return SettingsPropertyValue.Integer(key: key, value: defaultValue)
            case .enum(let key, let defaultValue, _):
                return SettingsPropertyValue.text(key: key, value: defaultValue)
            case .text(let key, let defaultValue):
                return SettingsPropertyValue.text(key: key, value: defaultValue)
            case .float(let key, let defaultValue):
                return SettingsPropertyValue.Float(key: key, value: defaultValue)
            }
        }
    }

    public var key: String {
        get {
            switch (self) {
            case .boolean(let key, _):
                return key
            case .integer(let key, _):
                return key
            case .enum(let key, _, _):
                return key
            case .text(let key, _):
                return key
            case .float(let key, _):
                return key
            }
        }
    }
}

public enum SettingsPropertyValue {
    case Integer(key: String, value: Int)
    case Float(key: String, value: Float64)
    case text(key: String, value: String)
    case Boolean(key: String, value: Bool)

    public var value: AnyObject {
        get {
            switch (self) {
            case .Integer(_, let value):
                return value as AnyObject
            case .Boolean(_, let value):
                return value as AnyObject
            case .text(_, let value):
                return value as AnyObject
            case .Float(_, let value):
                return value as AnyObject
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
            case .text(_, let value):
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
            case .text(let key, _):
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

open class GameSettings {
    open fileprivate(set) var properties: [SettingsProperty] = []

    open func getDefaultValues() -> SettingsValues {
        var v: SettingsValues = SettingsValues()
        for p in properties {
            v[p.key] = p.defaultValue
        }
        return v
    }

    open func getFromKey(_ key: String) -> SettingsProperty? {
        for p in properties {
            if p.key == key {
                return p
            }
        }
        return nil
    }

    open static func fromIdAndVersion(_ gameID: String, version: String, path: String, handler: @escaping (GameSettings?) -> Void) {
        let id = SettingsCache.createID(gameID, version: version)
        if let sc = SettingsCache.settings(id: id) {
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

    internal static func fromData(_ data: Data) -> GameSettings? {
        do {
            let object = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
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

    fileprivate func readDictionary(_ dict: [String: AnyObject]) -> Bool {
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

    fileprivate static func fromFile(_ filepath: String, handler: (GameSettings?, Data) -> Void) {
        let man = FileManager.default
        if man.fileExists(atPath: filepath) {
            if let data = man.contents(atPath: filepath) {
                let gs = GameSettings.fromData(data)
                handler(gs, data)
            } else {
                Log.error("reding settings at path \(filepath) failed")
                handler(nil, Data())
            }
        } else {
            Log.error("settings at path \(filepath) does not exist")
            handler(nil, Data())
        }
    }

    fileprivate static func fromUrl(_ url: String, handler: @escaping (GameSettings?, Data) -> Void) {
        NetworkFetcher.get(url) { (data: Data, error: OtsimoError) in
            switch (error) {
            case .none:
                let gs = GameSettings.fromData(data)
                handler(gs, data)
            default:
                Log.error("failed to fetch gamesettings \(error)")
                handler(nil, Data())
            }
        }
    }

    fileprivate func addProperty(_ key: String, prop: [String: AnyObject]) {
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

    fileprivate func addIntegerProperty(_ key: String, prop: [String: AnyObject]) {
        if let d = prop["default"] as? Int {
            properties.append(SettingsProperty.integer(key: key, defaultValue: d))
        } else {
            Log.error("failed to get default value of \(key)")
        }
    }

    fileprivate func addBooleanProperty(_ key: String, prop: [String: AnyObject]) {
        if let d = prop["default"] as? Bool {
            properties.append(SettingsProperty.boolean(key: key, defaultValue: d))
        } else {
            Log.error("failed to get default value of \(key)")
        }
    }

    fileprivate func addStringProperty(_ key: String, prop: [String: AnyObject]) {
        if let vs = prop["enum"] as? [String] {
            addEnumProperty(key, prop: prop, values: vs)
        } else if let d = prop["default"] as? String {
            properties.append(SettingsProperty.text(key: key, defaultValue: d))
        } else {
            Log.error("failed to get default value of \(key)")
        }
    }

    fileprivate func addEnumProperty(_ key: String, prop: [String: AnyObject], values: [String]) {
        if let d = prop["default"] as? String {
            properties.append(SettingsProperty.enum(key: key, defaultValue: d, values: values))
        } else {
            Log.error("failed to get default value of \(key)")
        }
    }
}
