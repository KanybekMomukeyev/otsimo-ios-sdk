//
//  Otsimo+Watch.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 19/02/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import OtsimoApiGrpc

extension Otsimo{
    func startWatch(callback: (OTSWatchEvent) -> Void) -> (watch:WatchProtocol?,error: OtsimoError){
        if let session = session{
            let watch = Watch(connection: connection!)
            watch.start(session, handler: callback)
            return (watch:watch, error: OtsimoError.None)
        }else{
            return (watch:nil,error:OtsimoError.NotLoggedIn(message: "not logged in"))
        }
    }
}