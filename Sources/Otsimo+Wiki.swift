//
//  Otsimo+Wiki.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 22/02/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation

import OtsimoApiGrpc

extension Otsimo: WikiApi {
    public func featuredContents(handler: (Int, [OTSContent], OtsimoError) -> Void) {
        if let connection = connection {
            if let ses = session {
                self.getProfile { prof, err in
                    if let profile = prof {
                        let req = OTSContentListRequest()
                        req.language = profile.language
                        if self.onlyProduction {
                            req.status = OTSContentListRequest_ListStatus.OnlyApproved
                        } else {
                            req.status = OTSContentListRequest_ListStatus.Both
                        }
                        req.sort = OTSContentListRequest_SortBy.Weight
                        connection.getContents(ses, req: req, handler: handler)
                    } else {
                        handler(0, [], OtsimoError.ServiceError(message: "failed to get profile"))
                    }
                }
            } else {
                handler(0, [], .NotLoggedIn(message: "not logged in, session is nil"))
            }
        } else {
            handler(0, [], .NotInitialized)
        }
    }

    public func contentsByDate(handler: (Int, [OTSContent], OtsimoError) -> Void) {
        if let connection = connection {
            if let ses = session {
                self.getProfile { prof, err in
                    if let profile = prof {
                        let req = OTSContentListRequest()
                        req.language = profile.language
                        if self.onlyProduction {
                            req.status = OTSContentListRequest_ListStatus.OnlyApproved
                        } else {
                            req.status = OTSContentListRequest_ListStatus.Both
                        }
                        req.sort = OTSContentListRequest_SortBy.Time
                        connection.getContents(ses, req: req, handler: handler)
                    } else {
                        handler(0, [], OtsimoError.ServiceError(message: "failed to get profile"))
                    }
                }
            } else {
                handler(0, [], .NotLoggedIn(message: "not logged in, session is nil"))
            }
        } else {
            handler(0, [], .NotInitialized)
        }
    }
}