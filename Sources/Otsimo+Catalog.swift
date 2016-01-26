//
//  Otsimo+Catalog.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 25/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation
import OtsimoApiGrpc

extension Otsimo: CatalogApi {
    
    // Catalog
    public func getCatalog(handler: (OTSCatalog?, OtsimoError) -> Void) {
        if let connection = connection {
            let req = OTSCatalogPullRequest()
            if let ses = session {
                req.profileId = ses.profileID
                connection.getCurrentCatalog(ses, req: req, handler: handler)
            } else {
                handler(nil, .NotLoggedIn(message: "not logged in, session is nil"))
            }
        } else {
            handler(nil, OtsimoError.NotInitialized)
        }
    }
}