//
//  Otsimo+Dashboard.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 09/03/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation

extension Otsimo: DashboardApi {
    public func dashboard(childID: String, lang: String, cacheTime: Int64?, handler: @escaping (Otsimo_DashboardItems?, OtsimoError) -> Void) {
        self.isReady({ handler(nil, $0) }) { c, s in
            c.getDashboard(s, childID: childID, lang: lang, time: cacheTime, handler: handler)
        }
    }
}
