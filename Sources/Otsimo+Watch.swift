//
//  Otsimo+Watch.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 19/02/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation

extension Otsimo: WatchApi {
    public func startWatch(callback: @escaping (Apipb_WatchEvent) -> Void) -> (watch: WatchProtocol?, error: OtsimoError) {
            if let session = session {
                let watch = Watch(connection: connection!)
                watch.start(session: session, handler: callback)
                return (watch: watch, error: OtsimoError.none)
            } else {
                return (watch: nil, error: OtsimoError.notLoggedIn(message: "not logged in"))
            }
    }
}
