//
//  ChildGame.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 07/02/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import OtsimoApiGrpc

class ChildGameInitializer {
    var callback: (ChildGame, OtsimoError) -> Void
    var childGame: ChildGame

    var prepareList: [() -> Void] = []
    var lastError: OtsimoError = OtsimoError.none

    fileprivate var isCanceled = false

    init(game: ChildGame, initSettings: Bool, initKeyValueStorage: Bool, handler: @escaping (ChildGame, OtsimoError) -> Void) {
        self.childGame = game
        self.callback = handler

        if let g = childGame.game {
            if g.gameManifest == nil {
                prepareList.append(prepareManifest)
            }
        } else {
            prepareList.append(prepareGame)
            prepareList.append(prepareManifest)
        }

        if initKeyValueStorage && game.keyvalue == nil {
            prepareList.append(prepareKeyValueStore)
        }

        if initSettings && game.settings == nil {
            prepareList.append(prepareSettings)
        }
    }

    func start() {
        next()
    }

    fileprivate func next() {
        if isCanceled { return }

        var call: (() -> Void)?

        switch (lastError) {
        case OtsimoError.none:
            if prepareList.count == 0 {
                childGame.initializer = nil
                callback(childGame, OtsimoError.none)
            } else {
                call = prepareList.removeFirst()
            }
        default:
            childGame.initializer = nil
            callback(childGame, lastError)
        }

        if let c = call {
            c()
        }
    }

    fileprivate func handleGetGame(_ game: Game?, error: OtsimoError) {
        if isCanceled { return }
        self.childGame.game = game
        lastError = error
        next()
    }

    fileprivate func prepareGame() {
        Otsimo.sharedInstance.getGame(id: childGame.entry.id_p, handler: handleGetGame)
    }

    fileprivate func prepareManifest() {
        childGame.game!.getManifest(handleGetManifest)
    }

    fileprivate func handleGetManifest(_ man: GameManifest?, error: OtsimoError) {
        if isCanceled { return }
        childGame.manifest = man
        lastError = error
        next()
    }

    fileprivate func prepareSettings() {
        if self.isCanceled { return }
        childGame.manifest!.getSettings {
            if self.isCanceled { return }
            self.childGame.settings = $0
            self.next()
        }
    }

    fileprivate func prepareKeyValueStore() {
        if self.isCanceled { return }
        childGame.manifest!.getKeyValueStore {
            if self.isCanceled { return }
            self.childGame.keyvalue = $0
            self.next()
        }
    }

    func cancel() {
        isCanceled = true
    }
}

open class ChildGame {
    open let entry: OTSChildGameEntry
    open let childID: String
    open fileprivate(set) var settingsValues: SettingsValues

    open internal(set) var game: Game?
    open internal(set) var manifest: GameManifest?
    open internal(set) var settings: GameSettings?
    open internal(set) var keyvalue: GameKeyValueStore?

    var initializer: ChildGameInitializer?

    open var gameID: String {
        get {
            return entry.id_p
        }
    }

    open var index: Int {
        get {
            return Int(entry.dashboardIndex)
        }
        set(value) {
            entry.dashboardIndex = Int32(value)
            Otsimo.sharedInstance.updateDashboardIndex(gameID: gameID, childID: childID, index: entry.dashboardIndex) { e in
                switch (e) {
                case .none:
                    Log.debug("updated dashboard index of \(self.gameID)")
                default:
                    if let d = Otsimo.sharedInstance.silentErrorDelegate {
                        Log.error("failed update dashboard index of \(self.gameID) error:\(e)")
                        d.silentError("child:index", err: e)
                    }
                }
            }
        }
    }

    open var isActive: Bool {
        get { return entry.active }
        set(value) {
            entry.active = value
            Otsimo.sharedInstance.updateActivationGame(gameID: gameID, childID: childID, activate: value) { e in
                switch (e) {
                case .none:
                    Log.debug("updated activation of \(self.gameID)")
                default:
                    if let d = Otsimo.sharedInstance.silentErrorDelegate {
                        Log.error("failed update activation of \(self.gameID) error:\(e)")
                        d.silentError("child:activate", err: e)
                    }
                }
            }
        }
    }

    public init(entry: OTSChildGameEntry, childID: String) {
        self.entry = entry
        self.childID = childID
        if let s = entry.settings {
            self.settingsValues = ChildGame.InitSettingsValues(s)
        } else {
            self.settingsValues = SettingsValues()
        }
    }

    open func cancelInitialize() {
        if let i = initializer {
            i.cancel()
            initializer = nil
        }
    }

    open func initialize(_ initSettings: Bool, initKeyValueStorage: Bool, handler: @escaping (ChildGame, OtsimoError) -> Void) {
        if let i = initializer {
            i.cancel()
            initializer = nil
        }

        let _init = ChildGameInitializer(game: self, initSettings: initSettings, initKeyValueStorage: initKeyValueStorage, handler: handler)
        self.initializer = _init
        _init.start()
    }

    open func valueFor(_ key: String) -> SettingsPropertyValue? {
        return settingsValues[key]
    }

    open func updateValue(_ value: SettingsPropertyValue) {
        settingsValues[value.key] = value
    }

    open func saveSettings(_ handler:@escaping (OtsimoError) -> Void) {
        if let data = ChildGame.DataOfSettingsValues(self.settingsValues){
            Otsimo.sharedInstance.updateSettings(gameID: gameID, childID: childID, settings: data, handler: handler)
        }
    }

    open static func InitSettingsValues(_ data: Data) -> SettingsValues {
        do {
            var sv = SettingsValues()
            if data.count > 0 {
                let object = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
                if let o = object as? [String: AnyObject] {
                    for (k, v) in o {
                        switch (v) {
                        case let f as Float64:
                            if floor(f) == f{
                                sv[k] = SettingsPropertyValue.Integer(key: k, value: Int(f))
                            }else{
                                sv[k] = SettingsPropertyValue.Float(key: k, value: f)
                            }
                        case let integer as Int:
                            sv[k] = SettingsPropertyValue.Integer(key: k, value: integer)
                        case let b as Bool:
                            sv[k] = SettingsPropertyValue.Boolean(key: k, value: b)
                            
                        case let str as String:
                            sv[k] = SettingsPropertyValue.text(key: k, value: str)
                        default:
                            Log.error("non supporting value type \(k)")
                        }
                    }
                }
            } else {
                Log.debug("Empty Settings Data")
            }
            return sv
        } catch {
            Log.error("ChildGame:InitSettingsValues-> Invalid JSON data for settings ,error: \(error)")
            return SettingsValues()
        }
    }

    open static func DataOfSettingsValues(_ settings: SettingsValues) -> Data! {
        var dictionary = [String: AnyObject]()

        for v in settings.values {
            dictionary[v.key] = v.value
        }

        return try? JSONSerialization.data(withJSONObject: dictionary, options: JSONSerialization.WritingOptions())
    }
}

extension OTSChild {
    public func getGames() -> [ChildGame] {
        var chs: [ChildGame] = []
        let gameEntries = gamesArray as AnyObject as! [OTSChildGameEntry]
        for e in gameEntries {
            chs.append(ChildGame(entry: e, childID: id_p))
        }
        return chs.sorted { $0.index < $1.index }
    }
}
