//
//  NetworkFetcher.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 04/03/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation

class NetworkFetcher {
    static func get(urlPath: String, handler: (data: NSData, error: OtsimoError) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: urlPath)!)
        request.HTTPMethod = "GET"
        request.timeoutInterval = 5

        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else { // check for fundamental networking error
                onMainThread { handler(data: NSData(), error: .NetworkError(message: "\(error)")) }
                return
            }
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 { // check for http errors
                onMainThread { handler(data: NSData(), error: .NetworkError(message: "\(error)")) }
                return
            }
            onMainThread { handler(data: data!, error: .None) }
        }
        task.resume()
    }
}