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
    var lastError: OtsimoError = OtsimoError.None

    private var isCanceled = false

    init(game: ChildGame, initSettings: Bool, initKeyValueStorage: Bool, handler: (ChildGame, OtsimoError) -> Void) {
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

    private func next() {
        if isCanceled { return }

        var call : (() -> Void)?

        switch (lastError) {
            case OtsimoError.None:
            if prepareList.count == 0 {
                childGame.initializer = nil
                callback(childGame, OtsimoError.None)
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

    private func handleGetGame(game: Game?, error: OtsimoError) {
        if isCanceled { return }
        self.childGame.game = game
        lastError = error
        next()
    }

    private func prepareGame() {
        Otsimo.sharedInstance.getGame(childGame.entry.id_p, handler: handleGetGame)
    }

    private func prepareManifest() {
        childGame.game!.getManifest(handleGetManifest)
    }

    private func handleGetManifest(man: GameManifest?, error: OtsimoError) {
        if isCanceled { return }
        childGame.manifest = man
        lastError = error
        next()
    }

    private func prepareSettings() {
        if self.isCanceled { return }
        childGame.manifest!.getSettings {
            if self.isCanceled { return }
            self.childGame.settings = $0
            self.next()
        }
    }

    private func prepareKeyValueStore() {
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

public class ChildGame {
    public let entry: OTSChildGameEntry
    public let childID: String
    public private(set) var settingsValues: SettingsValues

    public internal(set) var game: Game?
    public internal(set) var manifest: GameManifest?
    public internal(set) var settings: GameSettings?
    public internal(set) var keyvalue: GameKeyValueStore?

    var initializer: ChildGameInitializer?

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
            Otsimo.sharedInstance.updateDashboardIndex(gameID, childID: childID, index: entry.dashboardIndex) { e in
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
        get { return entry.active }
        set(value) {
            entry.active = value
            Otsimo.sharedInstance.updateActivationGame(gameID, childID: childID, activate: value) { e in
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

    public func cancelInitialize() {
        if let i = initializer {
            i.cancel()
            initializer = nil
        }
    }

    public func initialize(initSettings: Bool, initKeyValueStorage: Bool, handler: (ChildGame, OtsimoError) -> Void) {
        if let i = initializer {
            i.cancel()
            initializer = nil
        }

        let _init = ChildGameInitializer(game: self, initSettings: initSettings, initKeyValueStorage: initKeyValueStorage, handler: handler)
        self.initializer = _init
        _init.start()
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
        return chs.sort { $0.index < $1.index }
    }
}
