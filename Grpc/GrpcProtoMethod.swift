//
//  SwiftProtoMethod.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 27/02/2017.
//  Copyright © 2017 Otsimo. All rights reserved.
//

public class GrpcProtoMethod {
    let package: String
    let service: String
    let method: String
    
    init(package: String, service: String, method: String) {
        self.package = package
        self.service = service
        self.method = method
    }
    
    var httpPath: String {
        if self.package.characters.count > 0 {
            return "/\(self.package).\(self.service)/\(self.method)"
        } else {
            return "/\(self.service)/\(self.method)"
        }
    }
}
