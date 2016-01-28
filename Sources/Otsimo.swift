//
//  Otsimo.swift
//  OtsimoSDK
//
//  Created by Sercan Degirmenci on 07/12/15.
//  Copyright © 2015 Otsimo. All rights reserved.
//

import Foundation
import OtsimoApiGrpc
import gRPC

public class Otsimo {
    
    public static let sharedInstance = Otsimo()
    public var session: Session?
    internal var connection: Connection?
    public var useProductionGames: Bool = true
    public var languages: [String] = []
    public let cache: CacheProtocol
    
    public init() {
        cache = OtsimoCache()
    }
    
    public static func config(config: ClientConfig) {
        sharedInstance.useProductionGames = config.useProductionGames
        sharedInstance.connection = Connection(config: config)
        sharedInstance.recoverOldSessionIfExist()
        sharedInstance.languages.removeAll()
        sharedInstance.languages.appendContentsOf(NSLocale.preferredLanguages())
    }
    
    public func handleOpenURL(url: NSURL) {
        print("handleURL: ", url)
    }
    
    private func recoverOldSessionIfExist() {
        
    }
    
    internal func fixGameAssetUrl(id: String, version: String, rawUrl: String) -> String {
        let v = versionToUrl(version)
        return "\(connection!.config.publicContentUrl)/\(id)/\(v)/\(rawUrl)"
    }
}