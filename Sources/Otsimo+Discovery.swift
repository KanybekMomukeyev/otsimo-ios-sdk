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


func newStaticConfig() -> OtsimoServices{
    let base64Data = "CgdzdGFnaW5nEhpodHRwczovL2Nvbm5lY3Qub3RzaW1vLmNvbSABKhlzZXJ2aWNlcy5vdHNpbW8uY29tOjMwODUyMhlzZXJ2aWNlcy5vdHNpbW8uY29tOjMwODQ3OhlzZXJ2aWNlcy5vdHNpbW8uY29tOjMwODU4QhlzZXJ2aWNlcy5vdHNpbW8uY29tOjMwODU3ShlzZXJ2aWNlcy5vdHNpbW8uY29tOjMwODU5UhlzZXJ2aWNlcy5vdHNpbW8uY29tOjMwODYwWhlzZXJ2aWNlcy5vdHNpbW8uY29tOjMwODU0YiFodHRwczovL3NlcnZpY2VzLm90c2ltby5jb206MzA4NTFqG2h0dHBzOi8vYWNjb3VudHMub3RzaW1vLmNvbaIBJAoGaXNzdWVyEhpodHRwczovL2Nvbm5lY3Qub3RzaW1vLmNvbaIBJAoHY29udGVudBIZc2VydmljZXMub3RzaW1vLmNvbTozMDg1OaIBJQoIcmVnaXN0cnkSGXNlcnZpY2VzLm90c2ltby5jb206MzA4NTKiAScKCGFjY291bnRzEhtodHRwczovL2FjY291bnRzLm90c2ltby5jb22iASUKCGxpc3RlbmVyEhlzZXJ2aWNlcy5vdHNpbW8uY29tOjMwODQ3ogEmCglkYXNoYm9hcmQSGXNlcnZpY2VzLm90c2ltby5jb206MzA4NjCiASAKA2FwaRIZc2VydmljZXMub3RzaW1vLmNvbTozMDg1NKIBIgoFd2F0Y2gSGXNlcnZpY2VzLm90c2ltby5jb206MzA4NTiiASQKB2NhdGFsb2cSGXNlcnZpY2VzLm90c2ltby5jb206MzA4NTeqAUUKBGRpc2sSPWh0dHBzOi8vc2VydmljZXMub3RzaW1vLmNvbTozMDg1MS9wdWJsaWMve3suaWR9fS97ey52ZXJzaW9ufX2yAUwKAnRyEkYKAnRyEg4KBlTDvG3DvBIEKgJ0chIUCgVPdGl6bRILGgVPdGl6bSoCdHISGgoHT3l1bmxhchIPGgdPeXVubGFyKgJ0cjgBsgFHCgJlbhJBCgJlbhILCgNBbGwSBCoCZW4SFgoGQXV0aXNtEgwaBkF1dGlzbSoCZW4SFgoFR2FtZXMSDRoFR2FtZXMqAmVuOAG6ASAKG2NoaWxkLXdhcm5pbmctbWVzc2FnZS0xLjAuMhIBMboBSAoTY2hpbGQtZGVmYXVsdC1nYW1lcxIxNTcxNTJjMWY3OGVmNWMwMDAxODkyMjM5LDU3MTc0MDljYTlkYjM4MDAwMWY4MTQzZboBIAobY2hpbGQtd2FybmluZy1tZXNzYWdlLTEuMi4wEgExugEgChtjaGlsZC13YXJuaW5nLW1lc3NhZ2UtMS4xLjISATG6AU4KGWNoaWxkLWRlZmF1bHQtZ2FtZXMtMS4xLjASMTU3MTUyYzFmNzhlZjVjMDAwMTg5MjIzOSw1NzE3NDA5Y2E5ZGIzODAwMDFmODE0M2W6ARoKFWNoaWxkLXdhcm5pbmctbWVzc2FnZRIBMLoBTgoZY2hpbGQtZGVmYXVsdC1nYW1lcy0xLjIuMBIxNTcxNTJjMWY3OGVmNWMwMDAxODkyMjM5LDU3MTc0MDljYTlkYjM4MDAwMWY4MTQzZboBTgoZY2hpbGQtZGVmYXVsdC1nYW1lcy0xLjAuMhIxNTcxNTJjMWY3OGVmNWMwMDAxODkyMjM5LDU3MTc0MDljYTlkYjM4MDAwMWY4MTQzZboBTgoZY2hpbGQtZGVmYXVsdC1nYW1lcy0xLjEuMhIxNTcxNTJjMWY3OGVmNWMwMDAxODkyMjM5LDU3MTc0MDljYTlkYjM4MDAwMWY4MTQzZboBIAobY2hpbGQtd2FybmluZy1tZXNzYWdlLTEuMS4wEgEx"
   
    let data = Data(base64Encoded: base64Data)!
    let sc = try! OtsimoServices(data:  data)
    return sc
}


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

    public static func config(options: Configuration, useStaticConfig : Bool = false) {
        Otsimo.sharedInstance.cluster.discoveryUrl = options.discovery
        Otsimo.sharedInstance.cluster.env = options.environment
        
        if useStaticConfig{
            let rc = newStaticConfig()
            let cnf = rc.clientConfig
            cnf.clientID = options.clientID
            cnf.clientSecret = options.clientSecret
            cnf.appGroup = options.appGroupName
            if options.keychainName != "" {
                cnf.sharedKeyChain = options.keychainName
            }
            Otsimo.config(cnf)
            return
        }
        
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
                if let si = Otsimo.sharedInstance.sdkInitializing{
                    si(OtsimoError.notInitialized)
                }
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
        req.countryCode = Locale.current.regionCode
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
    
    internal func isReadyWithoutSession(_ notReady: @escaping (OtsimoError) -> Void, onReady: @escaping (Connection) -> Void) {
        if let c = connection {
            onReady(c)
        } else {
            if cluster.hasValue {
                Log.info("Otsimo sdk is not not initialized but trying again")
                
                Otsimo.configFromDiscoveryService(cluster.discoveryUrl, env: cluster.env, timeout: 5) { cc in
                    if let config = cc {
                        Otsimo.config(config)
                        if let c = self.connection {
                            onReady(c)
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
