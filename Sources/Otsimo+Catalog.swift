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
    public func getCatalog(handler: @escaping (OTSCatalog?, OtsimoError) -> Void) {
        self.getCatalogFromRemote { c, e in
            switch (e) {
            case .none:
                if let catalog = c {
                    handler(catalog, e)
                    return
                }
                fallthrough
            default:
                Otsimo.sharedInstance.cache.fetchCatalog() { cat in
                    Log.debug("fetched catalog result =\(cat)")
                    if let catalog = cat {
                        handler(catalog, .none)
                    } else {
                        handler(nil, .general(message: "Not Found"))
                    }
                }
            }
        }
    }

    fileprivate func getCatalogFromRemote(_ handler: @escaping (OTSCatalog?, OtsimoError) -> Void) {
        self.isReady({ handler(nil, $0) }) { c, s in
            let req = OTSCatalogPullRequest()
            req.profileId = s.profileID
            c.getCurrentCatalog(s, req: req) { res, err in
                if let catalog = res {
                    Otsimo.sharedInstance.cache.cacheCatalog(catalog)
                    handler(catalog, OtsimoError.none)
                } else {
                    handler(nil, err)
                }
            }
        }
    }
}
