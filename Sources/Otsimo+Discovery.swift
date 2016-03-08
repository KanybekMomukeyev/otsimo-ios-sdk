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

    internal static func configFromDiscoveryService(serviceUrl: String, env: String, handler: (cnf: ClientConfig?) -> Void) {
        let url = NSURL(string: serviceUrl)!

        if (url.scheme == "http") {
            GRPCCall.useInsecureConnectionsForHost(url.host)
        }
        let discovery = Discovery(host: url.host)
        let req = DiscoveryRequest()
        req.osName = "ios"
        req.sdkVersion = Otsimo.sdkVersion
        req.environment = env
        req.countryCode = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as! String
        discovery.getWithRequest(req) { os, err in
            handler(cnf: os?.clientConfig)
        }
    }
}