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
    private static let storageVersion = 28
    public static let sdkVersion: String = "1.0.6"
    public static let oauthSchema: String = "otsimoauth"
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
    private(set) public var languages: [String] = []
    internal let cache: CacheProtocol
    public var sessionStatusChanged: ((Session?) -> Void)?
    private(set) public var analytics: OtsimoAnalyticsProtocol!
    private(set) public var cluster: ClusterConfig = ClusterConfig()
    public var silentErrorDelegate: OtsimoErrorProtocol?

    public init() {
        cache = OtsimoCache()
    }

    internal static func config(config: ClientConfig) {
        print("[Otsimo_IOS_SDK_\(Otsimo.sdkVersion)]")

        sharedInstance.onlyProduction = config.onlyProduction
        sharedInstance.readLanguages()

        sharedInstance.connection = Connection(config: config)
        sharedInstance.analytics = Analytics(connection: sharedInstance.connection!)

        if isFirstLaunch() {
            sharedInstance.analytics.appEvent("start", payload: [String: AnyObject]())
        } else {
            sharedInstance.migrate(config)
        }
        sharedInstance.recoverOldSessionIfExist(config)
    }

    public func handleOpenURL(url: NSURL) -> Bool {
        analytics.appEvent("deeplink", payload: ["url": url.absoluteString])
        if url.scheme == Otsimo.oauthSchema {
            return true
        }
        return false
    }

    private func recoverOldSessionIfExist(config: ClientConfig) {
        Session.loadLastSession(config) { ses in
            self.session = ses
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
            NSUserDefaults.standardUserDefaults().setInteger(Otsimo.storageVersion, forKey: "OtsimoSDKStorageVersion")
            NSUserDefaults.standardUserDefaults().synchronize()
            return true
        }
        return false
    }

    private func migrate(config: ClientConfig) {
        let old = NSUserDefaults.standardUserDefaults().integerForKey("OtsimoSDKStorageVersion")
        if old == Otsimo.storageVersion {
            return
        }
        if old == 0 {
            Session.migrateToSharedKeyChain(config)
        }
        NSUserDefaults.standardUserDefaults().setInteger(Otsimo.storageVersion, forKey: "OtsimoSDKStorageVersion")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}
