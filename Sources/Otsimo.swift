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
    public var session: Session? {
        didSet {
            if let ssc = self.sessionStatusChanged {
                ssc(session)
            }
        }
    }
    internal var connection: Connection?
    public var useProductionGames: Bool = true
    public var languages: [String] = []
    public let cache: CacheProtocol
    public var sessionStatusChanged: ((Session?) -> Void)?
    
    public init() {
        cache = OtsimoCache()
    }
    
    public static func config(config: ClientConfig) {
        sharedInstance.useProductionGames = config.useProductionGames
        sharedInstance.connection = Connection(config: config)
        sharedInstance.recoverOldSessionIfExist(config)
        sharedInstance.readLanguages()
    }
    
    public func handleOpenURL(url: NSURL) {
        print("handleURL: ", url)
    }
    
    private func recoverOldSessionIfExist(config: ClientConfig) {
        Session.loadLastSession(config) {ses in
            self.session = ses
        }
    }
    
    public func fixGameAssetUrl(id: String, version: String, rawUrl: String) -> String {
        let v = versionToUrl(version)
        return "\(connection!.config.publicContentUrl)/\(id)/\(v)/\(rawUrl)"
    }
    
    func readLanguages() {
        languages.removeAll()
        for l in NSLocale.preferredLanguages() {
            languages.append(l.substringToIndex(l.startIndex.advancedBy(2)))
        }
    }
}