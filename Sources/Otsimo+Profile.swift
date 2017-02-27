//
//  Otsimo+Profile.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 25/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation

extension Otsimo: ProfileApi {

    public func updateProfile(_ profile: Apipb_Profile, handler: @escaping (_ error: OtsimoError) -> Void) {
        self.isReady(handler) { c, s in
            c.updateProfile(s, profile: profile, handler: handler)
        }
    }

    // Profile
    public func getProfile(_ handler: @escaping (Apipb_Profile?, OtsimoError) -> Void) {
        self.isReady({ handler(nil, $0) }) { c, s in
            c.getProfile(s, handler: handler)
        }
    }
}
