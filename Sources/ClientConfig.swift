//
//  ClientConfig.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 04/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation

public struct Configuration{
    public var discovery: String
    public var environment: String
    public var clientID: String
    public var clientSecret: String
    public var appGroupName: String
    public var keychainName: String
    
    public init(discovery: String,
                environment: String,
                clientID: String,
                clientSecret: String,
                appGroupName: String,
                keychainName: String){
        self.discovery = discovery
        self.environment = environment
        self.clientSecret = clientSecret
        self.clientID = clientID
        self.appGroupName = appGroupName
        self.keychainName = keychainName
    }
}

internal class ClientConfig {
    var issuer = ""
    var clientID = ""
    var clientSecret = ""
    var onlyProduction: Bool = true
    var apiGrpcUrl = ""
    var registryGrpcUrl = ""
    var authorizationEndpoint = ""
    var tokenEndpoint = ""
    var accountsServiceUrl = ""
    var contentGrpcUrl = ""
    var catalogGrpcUrl = ""
    var watchGrpcUrl = ""
    var listenerGrpcUrl = ""
    var publicContentUrl = ""
    var dashboardGrpcUrl = ""
    var useTls = false
    var caCert = ""
    var sharedKeyChain = ""
    var appGroup = ""
}