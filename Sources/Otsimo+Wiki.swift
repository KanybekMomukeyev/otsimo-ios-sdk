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

    public func contentsByCategory(category: String, sort: ContentSort, limit: Int32?, offset: Int32?, callback: (Int, [OTSContent], OtsimoError) -> Void) {

        if let connection = connection {
            if let ses = session {
                self.getProfile { prof, err in
                    if let profile = prof {
                        let req = OTSContentListRequest()
                        req.language = profile.language
                        req.category = category
                        req.onlyHtmlURL = true
                        if self.onlyProduction {
                            req.status = OTSContentListRequest_ListStatus.OnlyApproved
                        } else {
                            req.status = OTSContentListRequest_ListStatus.Both
                        }
                        switch (sort) {
                        case .DateAsc:
                            req.sort = OTSContentListRequest_SortBy.Time
                            req.order = OTSContentListRequest_SortOrder.Asc
                        case .DateDsc:
                            req.sort = OTSContentListRequest_SortBy.Time
                            req.order = OTSContentListRequest_SortOrder.Dsc
                        case .WeightAsc:
                            req.sort = OTSContentListRequest_SortBy.Weight
                            req.order = OTSContentListRequest_SortOrder.Asc
                        case .WeightDsc:
                            req.sort = OTSContentListRequest_SortBy.Weight
                            req.order = OTSContentListRequest_SortOrder.Dsc
                        }
                        if let l = limit {
                            req.limit = l
                        }
                        if let o = offset {
                            req.offset = o
                        }

                        connection.getContents(ses, req: req, handler: callback)
                    } else {
                        callback(0, [], OtsimoError.ServiceError(message: "failed to get profile"))
                    }
                }
            } else {
                callback(0, [], .NotLoggedIn(message: "not logged in, session is nil"))
            }
        } else {
            callback(0, [], .NotInitialized)
        }
    }

    public func featuredContents(handler: (Int, [OTSContent], OtsimoError) -> Void) {
        if let connection = connection {
            if let ses = session {
                self.getProfile { prof, err in
                    if let profile = prof {
                        let req = OTSContentListRequest()
                        req.language = profile.language
                        req.onlyHtmlURL = true
                        req.sort = OTSContentListRequest_SortBy.Weight
                        if self.onlyProduction {
                            req.status = OTSContentListRequest_ListStatus.OnlyApproved
                        } else {
                            req.status = OTSContentListRequest_ListStatus.Both
                        }
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
                        req.sort = OTSContentListRequest_SortBy.Time
                        req.onlyHtmlURL = true
                        if self.onlyProduction {
                            req.status = OTSContentListRequest_ListStatus.OnlyApproved
                        } else {
                            req.status = OTSContentListRequest_ListStatus.Both
                        }
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