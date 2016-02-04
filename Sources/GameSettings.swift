//
//  GameSettings.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 03/02/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import Haneke

public enum SettingsProperty {
    case Integer(key: String, defaultValue: Int)
    case Float(key: String, defaultValue: Float64)
    case Text(key: String, defaultValue: String)
    case Boolean(key: String, defaultValue: Bool)
    case Enum(key: String, defaultValue: String, values: [String])
}

public class GameSettings {
    public var properties: [SettingsProperty] = []
    
    public static func fromIdAndVersion(gameID: String, version: String, path: String, handler: (GameSettings?) -> Void) {
        let url = Otsimo.sharedInstance.fixGameAssetUrl(gameID, version: version, rawUrl: path)
        GameSettings.fromUrl(url, handler: handler)
    }
    
    public static func fromUrl(settingsUrl: String, handler: (GameSettings?) -> Void) {
        let cache = Shared.JSONCache
        let URL = NSURL(string: settingsUrl)
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

/*
 extension GameSettings: DataConvertible, DataRepresentable {
 }
 */
