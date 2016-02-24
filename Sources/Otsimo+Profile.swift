//
//  Otsimo+Profile.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 25/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import OtsimoApiGrpc

extension Otsimo: ProfileApi {

    public func updateProfile(profile: OTSProfile, handler: (error: OtsimoError) -> Void) {
        if let connection = connection {
            if let ses = session {
                connection.updateProfile(ses, profile: profile, handler: handler)
            } else {
                handler(error: .NotLoggedIn(message: "not logged in, session is nil"))
            }
        } else {
            handler(error: OtsimoError.NotInitialized)
        }
    }

    // Profile
    public func getProfile(handler: (OTSProfile?, OtsimoError) -> Void) {
        if let connection = connection {
            if let ses = session {
                connection.getProfile(ses, handler: handler)
            } else {
                handler(nil, .NotLoggedIn(message: "not logged in, session is nil"))
            }
        } else {
            handler(nil, OtsimoError.NotInitialized)
        }
    }
}
