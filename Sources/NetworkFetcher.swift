//
//  NetworkFetcher.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 04/03/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import Foundation

class NetworkFetcher {
    static func get(_ urlPath: String, handler: @escaping (_ data: Data, _ error: OtsimoError) -> Void) {
        var request = URLRequest(url: URL(string: urlPath)!)
        request.httpMethod = "GET"
        request.timeoutInterval = 5

        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil && data != nil else { // check for fundamental networking error
                onMainThread { handler(Data(), .networkError(message: "\(error)")) }
                return
            }
            if let httpStatus = response as? HTTPURLResponse , httpStatus.statusCode != 200 { // check for http errors
                onMainThread { handler(Data(), .networkError(message: "\(error)")) }
                return
            }
            onMainThread { handler(data!, .none) }
        }) 
        task.resume()
    }
}
