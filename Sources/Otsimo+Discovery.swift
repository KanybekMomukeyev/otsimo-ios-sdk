//
//  Otsimo+Discovery.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 09/03/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import grpc
import OtsimoApiGrpc

extension OtsimoServices {
    var clientConfig: ClientConfig {
        let cc = ClientConfig()
        cc.issuer = self.issuer
        cc.useTls = self.useTls
        cc.onlyProduction = self.isProduction

        cc.apiGrpcUrl = self.apiGrpc
        cc.contentGrpcUrl = self.contentGrpc
        cc.listenerGrpcUrl = self.listenerGrpc
        cc.registryGrpcUrl = self.registryGrpc
        cc.publicContentUrl = self.gameContent
        cc.watchGrpcUrl = self.watchGrpc
        cc.catalogGrpcUrl = self.catalogGrpc
        cc.dashboardGrpcUrl = self.dashboardGrpc
        cc.accountsServiceUrl = self.accounts

        return cc
    }
}

open class ClusterConfig {
    fileprivate(set) open var discoveryUrl: String = ""
    fileprivate(set) open var env: String = ""
    fileprivate(set) open var config: OtsimoServices?

    internal var configSet: Bool {
        return config != nil
    }

    var hasValue: Bool {
        return discoveryUrl != "" && env != ""
    }

    func storedData() -> OtsimoServices? {
        let data = UserDefaults.standard.data(forKey: "OtsimoClusterConfig")
        if let d = data {
            do {
                return try OtsimoServices(data: d)
            } catch {
                Log.error("failed to convert data to OtsimoServices object err=\(error)")
                return nil
            }
        }
        return nil
    }

    func store(_ svc: OtsimoServices) {
        config = svc
        if let d = svc.data() {
            UserDefaults.standard.set(d, forKey: "OtsimoClusterConfig")
            UserDefaults.standard.synchronize()
        }
    }

    open func diskStorageUrl() -> String {
        if config == nil {
            config = storedData()
        }
        guard let cc = config else {
            return "https://services.otsimo.com:30851/public/{{.id}}/{{.version}}"
        }
        for (k, v) in cc.gameStorageProviders {
            if k as! String == "disk" {
                return v as! String
            }
        }
        return "https://services.otsimo.com:30851/public/{{.id}}/{{.version}}"
    }

    open func remoteConfigs() -> [String: String] {
        if config == nil {
            config = storedData()
        }
        var dict = [String: String]()
        guard let cc = config else {
            return dict
        }
        for (k, v) in cc.configs {
            if let key = k as? String, let val = v as? String {
                dict[key] = val
            }
        }
        return dict
    }
}

extension Otsimo {

    public static func config(options: Configuration) {
        Otsimo.sharedInstance.cluster.discoveryUrl = options.discovery
        Otsimo.sharedInstance.cluster.env = options.environment

        self.configFromDiscoveryService(options.discovery, env: options.environment, timeout: options.discoveryTimout) { cc in
            if let config = cc {
                config.clientID = options.clientID
                config.clientSecret = options.clientSecret
                config.appGroup = options.appGroupName
                if options.keychainName != "" {
                    config.sharedKeyChain = options.keychainName
                }
                Otsimo.config(config)
            } else {
                Log.error("failed to get cluster info")
            }
        }
    }

    static func configFromDiscoveryService(_ serviceUrl: String, env: String, timeout: Double, handler: @escaping (_ cnf: ClientConfig?) -> Void) {
        let url = URL(string: serviceUrl)!
        let host: String = ((url as NSURL).port != nil) ? "\(url.host!):\((url as NSURL).port!)" : url.host!
        if (url.scheme == "http") {
            GRPCCall.useInsecureConnections(forHost: host)
        }
        let discovery = Discovery(host: host)
        let req = DiscoveryRequest()
        req.osName = "ios"
        req.sdkVersion = Otsimo.sdkVersion
        req.environment = env
        req.countryCode = (Locale.current as NSLocale).object(forKey: NSLocale.Key.countryCode) as! String
        req.appBundleId = Bundle.main.bundleIdentifier
        req.appBundleVersion = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        var isCompleted = false

        let RPC = discovery.rpcToGet(with: req) { os, err in
            isCompleted = true
            if let e = err {
                Log.error("failed to get cluster info err=\(e)")
            } else {
                Log.debug("got cluster info \(os)")
            }
            if let cluster = os {
                Otsimo.sharedInstance.cluster.store(cluster)
                handler(cluster.clientConfig)
            } else {
                if let cc = Otsimo.sharedInstance.cluster.storedData() {
                    handler(cc.clientConfig)
                } else {
                    handler(nil)
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            if !isCompleted {
                Log.error("Timeout to discovery.RPCToGetWithRequest")
                RPC.cancel()
            }
        }
        RPC.start()
    }

    internal func isReady(_ notReady: @escaping (OtsimoError) -> Void, onReady: @escaping (Connection, Session) -> Void) {
        if let c = connection {
            if let s = session {
                onReady(c, s)
            } else {
                notReady(.notLoggedIn(message: "not logged in, session is nil"))
            }
        } else {
            if cluster.hasValue {
                Log.info("Otsimo sdk is not not initialized but trying again")

                Otsimo.configFromDiscoveryService(cluster.discoveryUrl, env: cluster.env, timeout: 5) { cc in
                    if let config = cc {
                        Otsimo.config(config)
                        if let c = self.connection {
                            if let s = self.session {
                                onReady(c, s)
                            } else {
                                notReady(.notLoggedIn(message: "not logged in, session is nil"))
                            }
                        } else {
                            notReady(.notInitialized)
                        }
                    } else {
                        Log.error("failed to get cluster info, Again!!")
                        notReady(.notInitialized)
                    }
                }
            } else {
                notReady(.notInitialized)
            }
        }
    }
}
