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

    public func handleOpenURL(url: NSURL) {
        print("handleURL: ", url)
        analytics.appEvent("deeplink", payload: ["url": url.absoluteString])
    }

    private func recoverOldSessionIfExist(config: ClientConfig) {
        Session.loadLastSession(config) { ses in
            self.session = ses
        }
    }

    public func fixGameAssetUrl(id: String, version: String, rawUrl: String) -> String {
        let v = versionToUrl(version)
        return "\(connection!.config.publicContentUrl)/\(id)/\(v)/\(rawUrl)"
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
}