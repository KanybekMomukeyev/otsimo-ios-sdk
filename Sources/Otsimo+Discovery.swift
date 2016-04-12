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

extension Otsimo {

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
        discovery.getWithRequest(req) { os, err in
            if let err = err {
                Log.error("failed to get cluster info err=\(err)")
            } else {
                Log.debug("got cluster info \(os)")
            }
            handler(cnf: os?.clientConfig)
        }
    }
}