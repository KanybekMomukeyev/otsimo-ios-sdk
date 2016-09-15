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

    public func contentsByQuery(_ query: OTSContentListRequest, callback: @escaping (Int, [OTSContent], OtsimoError) -> Void) {
        self.isReady({ callback(0, [], $0) }) { c, s in
            query.onlyHtmlURL = true
            if self.onlyProduction {
                query.status = OTSContentListRequest_ListStatus.onlyApproved
            } else {
                query.status = OTSContentListRequest_ListStatus.both
            }
            c.getContents(s, req: query, handler: callback)
        }
    }

    public func content(_ slug: String, handler: @escaping (OTSContent?, OtsimoError) -> Void) {
        self.isReady({ handler(nil, $0) }) { c, s in
            c.getContent(s, slug: slug, handler: handler)
        }
    }

    public func contentsByCategory(_ category: String,
        sort: ContentSort,
        limit: Int32?,
        offset: Int32?,
        language: String,
        callback: @escaping (Int, [OTSContent], OtsimoError) -> Void)
    {
        self.isReady({ callback(0, [], $0) }) { c, s in
            let req = OTSContentListRequest()
            req.language = language
            req.category = category
            req.onlyHtmlURL = true
            if self.onlyProduction {
                req.status = OTSContentListRequest_ListStatus.onlyApproved
            } else {
                req.status = OTSContentListRequest_ListStatus.both
            }
            switch (sort) {
            case .dateAsc:
                req.sort = OTSContentListRequest_SortBy.time
                req.order = OTSContentListRequest_SortOrder.asc
            case .dateDsc:
                req.sort = OTSContentListRequest_SortBy.time
                req.order = OTSContentListRequest_SortOrder.dsc
            case .weightAsc:
                req.sort = OTSContentListRequest_SortBy.weight
                req.order = OTSContentListRequest_SortOrder.asc
            case .weightDsc:
                req.sort = OTSContentListRequest_SortBy.weight
                req.order = OTSContentListRequest_SortOrder.dsc
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

    public func wikiSegments() -> [SelfLearningSegment] {
        let data = self.cluster.config != nil ? self.cluster.config : self.cluster.storedData()
        if let d = data {
            if let lang = Otsimo.sharedInstance.preferredLanguage {
                if let a = d.selfLearningConfigs[lang] as? SelfLearningConfig {
                    let aa = a.segmentsArray as [AnyObject] as! [SelfLearningSegment]
                    return aa
                }
            } else {
                for l in Otsimo.sharedInstance.languages {
                    if let a = d.selfLearningConfigs[l] as? SelfLearningConfig {
                        let aa = a.segmentsArray as [AnyObject] as! [SelfLearningSegment]
                        return aa
                    }
                }
            }
        }
        return []
    }
}
