//
//  Otsimo.swift
//  OtsimoSDK
//
//  Created by Sercan Degirmenci on 07/12/15.
//  Copyright © 2015 Otsimo. All rights reserved.
//

import Foundation
import GRPCClient

open class Otsimo {
    fileprivate static let storageVersion = 28
    open static let sdkVersion: String = "2.0.0"
    open static let oauthSchema: String = "otsimoauth"
    open static let sharedInstance = Otsimo()
    open var session: Session? {
        didSet {
            if let ssc = self.sessionStatusChanged {
                ssc(self.session)
            }
            if let ses = session {
                analytics.start(session: ses)
            } else {
                analytics.stop(error: nil)
            }
        }
    }
    internal var connection: Connection?
    internal var onlyProduction: Bool = true
    internal var preferredLanguage: String?
    fileprivate(set) open var languages: [String] = []
    open let cache: CacheProtocol

    open var sessionStatusChanged: ((Session?) -> Void)?
    open var sdkInitializing: ((OtsimoError) -> Void)?

    fileprivate(set) open var analytics: OtsimoAnalyticsProtocol!
    fileprivate(set) open var cluster: ClusterConfig = ClusterConfig()
    open var silentErrorDelegate: OtsimoErrorProtocol?

    public init() {
        cache = OtsimoCache()
    }

    internal static func config(_ config: ClientConfig) {
        print("[Otsimo_IOS_SDK_\(Otsimo.sdkVersion)]")

        sharedInstance.onlyProduction = config.onlyProduction
        sharedInstance.readLanguages()

        sharedInstance.connection = Connection(config: config, interceptor: sharedInstance)
        sharedInstance.analytics = Analytics(connection: sharedInstance.connection!)

        if isFirstLaunch() {
            sharedInstance.analytics.appEvent(event: "start", payload: [String: AnyObject]())
        } else {
            sharedInstance.migrate(config)
        }
        sharedInstance.recoverOldSessionIfExist(config)
        if let it = sharedInstance.sdkInitializing {
            it(.none)
        }
    }

    open func handleOpenURL(_ url: URL) -> Bool {
        analytics.appEvent(event: "deeplink", payload: ["url": url.absoluteString as AnyObject])
        if url.scheme == Otsimo.oauthSchema {
            return true
        }
        return false
    }

    fileprivate func recoverOldSessionIfExist(_ config: ClientConfig) {
        Session.loadLastSession(config) { ses in
            if let exp = ses?.willTokenExpireIn(seconds: 3600), exp == true{
                ses?.refreshTokenNow { (_) in
                    onMainThread {
                        self.session = ses
                    }
                }
            }else{
                self.session = ses
            }
        }
    }

    open func setUserLanguage(_ lang: String?) {
        preferredLanguage = lang
    }

    func readLanguages() {
        languages.removeAll()
        for l in Locale.preferredLanguages {
            languages.append(l.substring(to: l.characters.index(l.startIndex, offsetBy: 2)))
        }
    }

    fileprivate static func isFirstLaunch() -> Bool {
        if !UserDefaults.standard.bool(forKey: "OtsimoSDKHasLaunchedOnce") {
            UserDefaults.standard.set(true, forKey: "OtsimoSDKHasLaunchedOnce")
            UserDefaults.standard.set(Otsimo.storageVersion, forKey: "OtsimoSDKStorageVersion")
            UserDefaults.standard.synchronize()
            return true
        }
        return false
    }

    fileprivate func migrate(_ config: ClientConfig) {
        let old = UserDefaults.standard.integer(forKey: "OtsimoSDKStorageVersion")
        if old == Otsimo.storageVersion {
            return
        }
        if old == 0 {
            Session.migrateToSharedKeyChain(config)
        }
        UserDefaults.standard.set(Otsimo.storageVersion, forKey: "OtsimoSDKStorageVersion")
        UserDefaults.standard.synchronize()
    }

    open var apiService: ApiService? {
        return self.connection?.apiService
    }
    
    open var catalogService: CatalogService? {
        return self.connection?.catalogService
    }

    open var watchService: WatchService? {
        return self.connection?.watchService
    }

    open var listenerService: ListenerService? {
        return self.connection?.listenerService
    }

    open var registryService: RegistryService? {
        return self.connection?.registryService
    }

    open var contentService: ContentService? {
        return self.connection?.contentService
    }

    open var dashboardService: DashboardService? {
        return self.connection?.dashboardService
    }

    open var simplifiedAnalytics: SimplifiedAnalytics? {
        return self.connection?.simplifiedAnalytics
    }
}

extension Otsimo: GrpcInterceptor{
    public var id: String {
        return "otsimo-auth"
    }
    
    public func intercept(_ call: GRPCCall){
        if let s = self.session{
            call.oauth2AccessToken = s.accessToken
            if s.willTokenExpireIn(seconds: 300){
                s.refreshTokenNow({ (_) in
                    Log.info("access token refreshed")
                })
            }
        }
    }
}

