//
//  Otsimo+Dashboard.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 09/03/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import OtsimoApiGrpc

extension Otsimo : DashboardApi {
    public func dashboard(childID: String, handler: (DashboardItems?, OtsimoError) -> Void) {
        if let connection = connection {
            if let ses = session {
                connection.getDashboard(ses, childID: childID, handler: handler)
            } else {
                handler(nil, .NotLoggedIn(message: "not logged in, session is nil"))
            }
        } else {
            handler(nil, OtsimoError.NotInitialized)
        }
    }
}