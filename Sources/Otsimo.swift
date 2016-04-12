//
//  Otsimo.swift
//  OtsimoSDK
//
//  Created by Sercan Degirmenci on 07/12/15.
//  Copyright © 2015 Otsimo. All rights reserved.
//

import Foundation
import OtsimoApiGrpc

public class Otsimo {
    public static let sdkVersion: String = "0.1.0"
    public static let sharedInstance = Otsimo()
    public var session: Session? {
        didSet {
            if let ssc = self.sessionStatusChanged {
                ssc(self.session)
            }
            if let ses = session {
                analytics.start(ses)
            } else {
                analytics.stop(nil)
            }
        }
    }
    internal var connection: Connection?
    internal var onlyProduction: Bool = true
    internal var preferredLanguage: String?
    public var languages: [String] = []
    internal let cache: CacheProtocol
    public var sessionStatusChanged: ((Session?) -> Void)?
    public var analytics: OtsimoAnalyticsProtocol!

    public init() {
        cache = OtsimoCache()
    }

    public static func config(config: ClientConfig) {
        sharedInstance.onlyProduction = config.onlyProduction
        sharedInstance.readLanguages()

        sharedInstance.connection = Connection(config: config)
        sharedInstance.analytics = Analytics(connection: sharedInstance.connection!)

        sharedInstance.recoverOldSessionIfExist(config)

        if isFirstLaunch() {
            sharedInstance.analytics.appEvent("start", payload: [String: AnyObject]())
        }
    }

    public static func config(discovery: String, env: String) {
        self.configFromDiscoveryService(discovery, env: env) { cc in
            if let config = cc {
                sharedInstance.onlyProduction = config.onlyProduction
                sharedInstance.readLanguages()

                sharedInstance.connection = Connection(config: config)
                sharedInstance.analytics = Analytics(connection: sharedInstance.connection!)

                sharedInstance.recoverOldSessionIfExist(config)

                if isFirstLaunch() {
                    sharedInstance.analytics.appEvent("start", payload: [String: AnyObject]())
                }
            } else {
                Log.error("failed to get cluster info")
            }
        }
    }

    public func handleOpenURL(url: NSURL) {
        Log.info("handleURL: \(url)")
        analytics.appEvent("deeplink", payload: ["url": url.absoluteString])
    }

    private func recoverOldSessionIfExist(config: ClientConfig) {
        Session.loadLastSession(config) { ses in
            self.session = ses
        }
    }

    public var gamesDir: String {
        let root = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let libraryDirectoryPath: String = root[0]
        return libraryDirectoryPath.stringByAppendingString("/Games")
    }

    internal func isLocallyAvailable(gameID: String, version: String) -> Bool {
        let path = gamesDir.stringByAppendingString("/\(gameID)/\(version)/otsimo.json")
        return NSFileManager.defaultManager().fileExistsAtPath(path)
    }

    public func fixGameAssetUrl(id: String, version: String, rawUrl: String, nolocal: Bool = false) -> String {
        if !nolocal && isLocallyAvailable(id, version: version) {
            return gamesDir.stringByAppendingString("/\(id)/\(version)/\(rawUrl)")
        } else {
            let v = versionToUrl(version)
            return "\(connection!.config.publicContentUrl)/\(id)/\(v)/\(rawUrl)"
        }
    }

    public func setUserLanguage(lang: String?) {
        preferredLanguage = lang
    }

    func readLanguages() {
        languages.removeAll()
        for l in NSLocale.preferredLanguages() {
            languages.append(l.substringToIndex(l.startIndex.advancedBy(2)))
        }
    }

    private static func isFirstLaunch() -> Bool {
        if !NSUserDefaults.standardUserDefaults().boolForKey("OtsimoSDKHasLaunchedOnce") {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "OtsimoSDKHasLaunchedOnce")
            NSUserDefaults.standardUserDefaults().synchronize()
            return true
        }
        return false
    }

    internal func isReady(notReady: (OtsimoError) -> Void, onReady: (Connection, Session) -> Void) {
        if let c = connection {
            if let s = session {
                onReady(c, s)
            } else {
                notReady(.NotLoggedIn(message: "not logged in, session is nil"))
            }
        } else {
            notReady(OtsimoError.NotInitialized)
        }
    }
}
