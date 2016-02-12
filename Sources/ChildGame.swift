//
//  ChildGame.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 07/02/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import OtsimoApiGrpc

public class ChildGame {
    public let entry: OTSChildGameEntry
    public let childID: String
    public private(set) var settingsValues: SettingsValues
    
    public private(set) var game: Game?
    public private(set) var manifest: GameManifest?
    public private(set) var settings: GameSettings?
    public private(set) var keyvalue: GameKeyValueStore?
    public var gameID: String {
        get {
            return entry.id_p
        }
    }
    
    public var index: Int {
        get {
            return Int(entry.dashboardIndex)
        }
        set(value) {
            entry.dashboardIndex = Int32(value)
            Otsimo.sharedInstance.updateDashboardIndex(gameID, childID: childID, index: entry.dashboardIndex) {e in
                switch (e) {
                case .None:
                    Log.debug("updated dashboard index of \(self.gameID)")
                default:
                    Log.error("failed update dashboard index of \(self.gameID) error:\(e)")
                }
            }
        }
    }
    
    public var isActive: Bool {
        get {return entry.active}
        set(value) {
            entry.active = value
            Otsimo.sharedInstance.updateActivationGame(gameID, childID: childID, activate: value) {e in
                switch (e) {
                case .None:
                    Log.debug("updated activation of \(self.gameID)")
                default:
                    Log.error("failed update activation of \(self.gameID) error:\(e)")
                }
            }
        }
    }
    
    public init(entry: OTSChildGameEntry, childID: String) {
        self.entry = entry
        self.childID = childID
        self.settingsValues = ChildGame.InitSettingsValues(entry.settings)
    }
    
    public func initialize(initSettings: Bool, initKeyValueStorage: Bool, handler: (ChildGame, OtsimoError) -> Void) {
        var targetFetchAmount: Int = 0
        if initSettings {
            targetFetchAmount += 1
        }
        if initKeyValueStorage {
            targetFetchAmount += 1
        }
        
        Otsimo.sharedInstance.getGame(entry.id_p) {_game, error in
            self.game = _game
            switch (error) {
            case .None:
                self.game!.getManifest {m, e in
                    self.manifest = m
                    if targetFetchAmount == 0 {
                        handler(self, OtsimoError.None)
                        return
                    }
                    
                    if let man = self.manifest {
                        var fc = 0
                        
                        if initSettings {
                            man.getSettings {
                                self.settings = $0
                                fc += 1
                                if fc == targetFetchAmount {
                                    handler(self, OtsimoError.None)
                                }
                            }
                        }
                        if initKeyValueStorage {
                            man.getKeyValueStore {
                                self.keyvalue = $0
                                fc += 1
                                if fc == targetFetchAmount {
                                    handler(self, OtsimoError.None)
                                }
                            }
                        }
                    } else {
                        handler(self, e)
                    }
                }
            default:
                handler(self, error)
            }
        }
    }
    
    public func valueFor(key: String) -> SettingsPropertyValue? {
        return settingsValues[key]
    }
    
    public func updateValue(value: SettingsPropertyValue) {
        settingsValues[value.key] = value
    }
    
    public func saveSettings(handler: (OtsimoError) -> Void) {
        let data = ChildGame.DataOfSettingsValues(self.settingsValues)
        Otsimo.sharedInstance.updateSettings(gameID, childID: childID, settings: data, handler: handler)
    }
    
    public static func InitSettingsValues(data: NSData) -> SettingsValues {
        do {
            let object : AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
            var sv = SettingsValues()
            if let o = object as? [String: AnyObject] {
                for (k, v) in o {
                    switch (v) {
                    case let integer as Int:
                        sv[k] = SettingsPropertyValue.Integer(key: k, value: integer)
                    case let f as Float64:
                        sv[k] = SettingsPropertyValue.Float(key: k, value: f)
                    case let str as String:
                        sv[k] = SettingsPropertyValue.Text(key: k, value: str)
                    default:
                        Log.debug("non supporting value type \(k)")
                    }
                }
            }
            return sv
        } catch {
            Log.error("Invalid JSON data for settings ,error: \(error)")
            return SettingsValues()
        }
    }
    
    public static func DataOfSettingsValues(settings: SettingsValues) -> NSData! {
        var dictionary = [String: AnyObject]()
        
        for v in settings.values {
            dictionary[v.key] = v.value
        }
        
        return try? NSJSONSerialization.dataWithJSONObject(dictionary, options: NSJSONWritingOptions())
    }
}

extension OTSChild {
    public func getGames() -> [ChildGame] {
        var chs: [ChildGame] = []
        let gameEntries = gamesArray as AnyObject as! [OTSChildGameEntry]
        for e in gameEntries {
            chs.append(ChildGame(entry: e, childID: id_p))
        }
        return chs.sort {$0.index < $1.index}
    }
}
