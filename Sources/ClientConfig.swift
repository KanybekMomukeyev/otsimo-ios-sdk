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
    internal var apiGrpcUrl = ""
    internal var registryGrpcUrl = ""
    internal var authorizationEndpoint = ""
    internal var tokenEndpoint = ""
    internal var accountsServiceUrl = ""
    internal var useTls = false
    internal var caCert = ""
    internal var useKeychain = false
    
    public static func development(clientID: String, host: String?) -> ClientConfig {
        var ip = "192.168.5.151"
        if host != nil {
            ip = host!
        }
        
        let cc = ClientConfig()
        cc.issuer = "http://\(ip):18848"
        cc.apiGrpcUrl = "\(ip):18854"
        cc.clientID = clientID
        cc.registryGrpcUrl = "\(ip):18852"
        cc.authorizationEndpoint = "http://\(ip):18848/auth"
        cc.tokenEndpoint = "http://\(ip):18848/token"
        cc.accountsServiceUrl = "http://\(ip):18856"
        cc.useTls = false
        return cc
    }
}