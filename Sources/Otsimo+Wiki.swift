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
    public func contentsByCategory(category: String,
        sort: ContentSort,
        limit: Int32?,
        offset: Int32?,
        language: String,
        callback: (Int, [OTSContent], OtsimoError) -> Void)
    {
        self.isReady({ callback(0, [], $0)}) { c, s in
            let req = OTSContentListRequest()
            req.language = language
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
            c.getContents(s, req: req, handler: callback)
        }
    }
}