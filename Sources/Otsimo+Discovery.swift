//
//  Otsimo+Discovery.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 09/03/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import gRPC
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

public class ClusterConfig {
    private(set) public var discoveryUrl: String = ""
    private(set) public var env: String = ""
    private(set) public var config: OtsimoServices?

    internal var configSet: Bool {
        return config != nil
    }

    var hasValue: Bool {
        return discoveryUrl != "" && env != ""
    }

    func storedData() -> OtsimoServices? {
        let data = NSUserDefaults.standardUserDefaults().dataForKey("OtsimoClusterConfig")
        if let d = data {
            var error: NSError? = nil
            let svc = OtsimoServices(data: d, error: &error)
            if error == nil {
                return svc
            }
        }
        return nil
    }

    func store(svc: OtsimoServices) {
        config = svc
        if let d = svc.data() {
            NSUserDefaults.standardUserDefaults().setObject(d, forKey: "OtsimoClusterConfig")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

    public func getDiskStorageUrl() -> String {
        if config == nil {
            config = storedData()
        }
        guard let cc = config else {
            return "https://services.sercand.com:30851/public/{{.id}}/{{.version}}"
        }
        for (k, v) in cc.gameStorageProviders {
            if k as! String == "disk" {
                return v as! String
            }
        }
        return "https://services.sercand.com:30851/public/{{.id}}/{{.version}}"
    }
}

extension Otsimo {

    public static func config(discovery: String, env: String, clientID: String, clientSecret: String) {
        Otsimo.sharedInstance.cluster.discoveryUrl = discovery
        Otsimo.sharedInstance.cluster.env = env

        self.configFromDiscoveryService(discovery, env: env) { cc in
            if let config = cc {
                config.clientID = clientID
                config.clientSecret = clientSecret
                Otsimo.config(config)
            } else {
                Log.error("failed to get cluster info")
            }
        }
    }

    public static func configFromDiscoveryService(serviceUrl: String, env: String, handler: (cnf: ClientConfig?) -> Void) {
        let url = NSURL(string: serviceUrl)!
        let host: String = (url.port != nil) ? "\(url.host!):\(url.port!)" : url.host!
        if (url.scheme == "http") {
            GRPCCall.useInsecureConnectionsForHost(host)
        }
        let discovery = Discovery(host: host)
        let req = DiscoveryRequest()
        req.osName = "ios"
        req.sdkVersion = Otsimo.sdkVersion
        req.environment = env
        req.countryCode = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as! String
        req.appBundleId = NSBundle.mainBundle().bundleIdentifier
        req.appBundleVersion = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as! String
        var isCompleted = false
        
        let RPC = discovery.RPCToGetWithRequest(req) { os, err in
            isCompleted = true
            if let e = err {
                Log.error("failed to get cluster info err=\(e)")
            } else {
                Log.debug("got cluster info \(os)")
            }
            if let cluster = os {
                Otsimo.sharedInstance.cluster.store(cluster)
                handler(cnf: cluster.clientConfig)
            } else {
                if let cc = Otsimo.sharedInstance.cluster.storedData() {
                    handler(cnf: cc.clientConfig)
                } else {
                    handler(cnf: nil)
                }
            }
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC) * 5), dispatch_get_main_queue()) {
            if !isCompleted {
                Log.error("Timeout to discovery.RPCToGetWithRequest")
                RPC.cancel()
            }
        }
        RPC.start()
    }

    internal func isReady(notReady: (OtsimoError) -> Void, onReady: (Connection, Session) -> Void) {
        if let c = connection {
            if let s = session {
                onReady(c, s)
            } else {
                notReady(.NotLoggedIn(message: "not logged in, session is nil"))
            }
        } else {
            if cluster.hasValue {
                Log.info("Otsimo sdk is not not initialized but trying again")

                Otsimo.configFromDiscoveryService(cluster.discoveryUrl, env: cluster.env) { cc in
                    if let config = cc {
                        Otsimo.config(config)
                        if let c = self.connection {
                            if let s = self.session {
                                onReady(c, s)
                            } else {
                                notReady(.NotLoggedIn(message: "not logged in, session is nil"))
                            }
                        } else {
                            notReady(OtsimoError.NotInitialized)
                        }
                    } else {
                        Log.error("failed to get cluster info, Again!!")
                        notReady(OtsimoError.NotInitialized)
                    }
                }
            } else {
                notReady(OtsimoError.NotInitialized)
            }
        }
    }
}