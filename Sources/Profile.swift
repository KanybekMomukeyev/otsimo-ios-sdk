//
//  Profile.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 08/12/15.
//  Copyright © 2015 Otsimo. All rights reserved.
//

public class Profile {

    public var userID: String = ""

    public var email: String = ""

    public var firstName: String = ""

    public var lastName: String = ""

    public var language: String = ""

    public var address: Address?

    public var name: String {
        get {
            return "\(firstName) \(lastName)"
        }
    }
}

public class Address {
    public var streetAddress: String = ""
    public var city: String = ""
    public var state: String = ""
    public var zipCode: String = ""
    public var countryCode: String = ""
}