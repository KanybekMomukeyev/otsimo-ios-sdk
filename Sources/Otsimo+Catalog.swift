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
        self.getCatalogFromRemote { c, e in
            switch (e) {
            case .None:
                if let catalog = c {
                    handler(catalog, e)
                    return
                }
                fallthrough
            default:
                Otsimo.sharedInstance.cache.fetchCatalog() { cat in
                    if let catalog = cat {
                        handler(catalog, .None)
                    } else {
                        handler(nil, .General(message: "Not Found"))
                    }
                }
            }
        }
    }

    private func getCatalogFromRemote(handler: (OTSCatalog?, OtsimoError) -> Void) {
        if let connection = connection {
            let req = OTSCatalogPullRequest()
            if let ses = session {
                req.profileId = ses.profileID
                connection.getCurrentCatalog(ses, req: req) { res, err in
                    if let catalog = res {
                        Otsimo.sharedInstance.cache.cacheCatalog(catalog)
                        handler(catalog, OtsimoError.None)
                    } else {
                        handler(nil, err)
                    }
                }
            } else {
                handler(nil, .NotLoggedIn(message: "not logged in, session is nil"))
            }
        } else {
            handler(nil, OtsimoError.NotInitialized)
        }
    }
}
