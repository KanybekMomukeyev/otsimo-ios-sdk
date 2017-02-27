//
//  Otsimo+Wiki.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 22/02/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation

extension Otsimo: WikiApi {

    public func contentsByQuery(_ query: Apipb_ContentListRequest, callback: @escaping (Int, [Apipb_Content], OtsimoError) -> Void) {
        self.isReady({ callback(0, [], $0) }) { c, s in
            /*if self.onlyProduction {
                query.status = Apipb_ContentListRequest.ListStatus.onlyApproved
            } else {
                query.status = Apipb_ContentListRequest.ListStatus.both
            }*/
            c.getContents(s, req: query, handler: callback)
        }
    }

    public func content(_ slug: String, handler: @escaping (Apipb_Content?, OtsimoError) -> Void) {
        self.isReady({ handler(nil, $0) }) { c, s in
            c.getContent(s, slug: slug, handler: handler)
        }
    }

    public func wikiSegments() -> [Apipb_SelfLearningSegment] {
        let data = self.cluster.config != nil ? self.cluster.config : self.cluster.storedData()
        if let d = data {
            if let lang = Otsimo.sharedInstance.preferredLanguage {
                if let a = d.selfLearningConfigs[lang] {
                    return a.segments
                }
            } else {
                for l in Otsimo.sharedInstance.languages {
                    if let a = d.selfLearningConfigs[l] {
                        return a.segments
                    }
                }
            }
        }
        return []
    }
}
