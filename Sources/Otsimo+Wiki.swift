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
