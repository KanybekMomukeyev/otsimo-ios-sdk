//
//  Log.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 25/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation

public enum LogLevel: Int {
    case Debug = 1
    case Info = 2
    case Warning = 3
    case Error = 4
    case Severe = 5
}

public class Log {
    static var logLevel: LogLevel = LogLevel.Info
    public static func setLevel(level: LogLevel) {
        logLevel = level
    }

    public static func debug(message: String) {
        log(.Debug, message: message)
    }

    public static func info(message: String) {
        log(.Info, message: message)
    }

    public static func warm(message: String) {
        log(.Warning, message: message)
    }

    public static func error(message: String) {
        log(.Error, message: message)
    }

    public static func severe(message: String) {
        log(.Severe, message: message)
    }

    private static func log(level: LogLevel, message: String) {
        if level.rawValue >= logLevel.rawValue {
            print("[\(level)] \(message)")
        }
    }
}