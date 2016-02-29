//
//  ClientConfig.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 04/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation

public class ClientConfig {
    internal var issuer = ""
    public var clientID = ""
    public var onlyProduction: Bool = true
    internal var apiGrpcUrl = ""
    internal var registryGrpcUrl = ""
    internal var authorizationEndpoint = ""
    internal var tokenEndpoint = ""
    internal var accountsServiceUrl = ""
    internal var contentGrpcUrl = ""
    internal var catalogGrpcUrl = ""
    internal var watchGrpcUrl = ""
    internal var listenerGrpcUrl = ""
    internal var publicContentUrl = ""

    internal var useTls = false
    internal var caCert = ""
    internal var useKeychain = false

    public static func development(clientID: String, host: String?) -> ClientConfig {
        var ip = "192.168.2.200"
        if host != nil {
            ip = host!
        }

        let cc = ClientConfig()
        cc.issuer = "http://\(ip):18848"
        cc.apiGrpcUrl = "\(ip):18854"
        cc.clientID = clientID
        cc.registryGrpcUrl = "\(ip):18852"
        cc.watchGrpcUrl = "\(ip):18858"
        cc.catalogGrpcUrl = "\(ip):18857"
        cc.listenerGrpcUrl = "\(ip):18847"
        cc.contentGrpcUrl = "\(ip):18859"
        cc.publicContentUrl = "http://\(ip):18851/public"
        cc.authorizationEndpoint = "http://\(ip):18848/auth"
        cc.tokenEndpoint = "http://\(ip):18848/token"
        cc.accountsServiceUrl = "http://\(ip):18856"

        cc.useTls = false
        cc.onlyProduction = false
        Log.setLevel(LogLevel.Debug)
        return cc
    }

    public static func sandbox(clientID: String) -> ClientConfig {
        let cc = ClientConfig()

        cc.clientID = clientID

        cc.issuer = "https://connect.otsimo.xyz"

        cc.apiGrpcUrl = "api.otsimo.xyz"
        cc.registryGrpcUrl = "registry.otsimo.xyz"
        cc.watchGrpcUrl = "watch.otsimo.xyz"
        cc.catalogGrpcUrl = "catalog.otsimo.xyz"
        cc.listenerGrpcUrl = "listener.otsimo.xyz"
        cc.contentGrpcUrl = "content.otsimo.xyz"
        cc.publicContentUrl = "https://games.otsimo.xyz/public"
        cc.authorizationEndpoint = "https://connect.otsimo.xyz/auth"
        cc.tokenEndpoint = "https://connect.otsimo.xyz/token"
        cc.accountsServiceUrl = "https://accounts.otsimo.xyz"

        cc.useTls = true
        cc.onlyProduction = true
        return cc
    }

    public static func production(clientID: String) -> ClientConfig {
        let cc = ClientConfig()

        cc.clientID = clientID

        cc.issuer = "https://connect.otsimo.com"

        cc.apiGrpcUrl = "api.otsimo.com"
        cc.registryGrpcUrl = "registry.otsimo.com"
        cc.watchGrpcUrl = "watch.otsimo.com"
        cc.catalogGrpcUrl = "catalog.otsimo.com"
        cc.listenerGrpcUrl = "listener.otsimo.com"
        cc.contentGrpcUrl = "content.otsimo.com"
        cc.publicContentUrl = "https://games.otsimo.com/public"
        cc.authorizationEndpoint = "https://connect.otsimo.com/auth"
        cc.tokenEndpoint = "https://connect.otsimo.com/token"
        cc.accountsServiceUrl = "https://accounts.otsimo.com"

        cc.useTls = true
        cc.onlyProduction = true
        return cc
    }
}