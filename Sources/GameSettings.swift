
//
//  GameSettings.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 03/02/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation

public enum SettingsEntry {
    case Integer(key: String, defaultValue: Int)
    case Float(key: String, defaultValue: Float64)
    case Text(key: String, defaultValue: String)
    case Boolean(key: String, defaultValue: Bool)
    case Enum(key: String, defaultValue: String, values: [String])
}

public class GameSettings {
    public var properties: [SettingsEntry] = []
}

/*
 extension GameSettings: DataConvertible, DataRepresentable {
 }
 */
