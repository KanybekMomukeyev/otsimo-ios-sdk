//
//  ClientConfig.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 04/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation

public struct Configuration{
    var discovery: String
    var environment: String
    var clientID: String
    var clientSecret: String
    var appGroupName: String
    var keychainName: String
}

internal class ClientConfig {
    internal var issuer = ""
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