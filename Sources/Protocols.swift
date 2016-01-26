//
//  Account.swift
//  OtsimoSDK
//
//  Created by Sercan Değirmenci on 25/01/16.
//  Copyright © 2016 Otsimo. All rights reserved.
//

import OtsimoApiGrpc

public protocol AccountApi {
    
    func login(email: String, password: String, handler: (res: TokenResult) -> Void)
    
    func register(data: RegistrationData, handler: (res: TokenResult) -> Void)
    
    func logout()
    
    func changeEmail(newEmail: String, handler: (OtsimoError) -> Void)
    
    func changePassword(old: String, newPassword: String, handler: (OtsimoError) -> Void)
}

public protocol ProfileApi {
    
    func getProfile(handler: (OTSProfile?, OtsimoError) -> Void)
    
    func updateProfile(profile: OTSProfile, handler: (error: OtsimoError) -> Void)
}

public protocol ChildApi {
    func addChild(firstName: String, lastName: String, gender: OTSGender,
        birthDay: NSDate, language: String, handler: (res: OtsimoError) -> Void)
    
    func getChild(id: String, handler: (res: OTSChild?, err: OtsimoError) -> Void)
    
    func getChildren(handler: (res: [OTSChild], err: OtsimoError) -> Void)
    
    func addGameToChild(gameID: String, childID: String, index: Int32, settings: NSData, handler: (error: OtsimoError) -> Void)
    
    func updateActivationGame(gameID: String, childID: String, activate: Bool, handler: (error: OtsimoError) -> Void)
    
    func updateSettings(gameID: String, childID: String, settings: NSData, handler: (error: OtsimoError) -> Void)
    
    func updateDashboardIndex(gameID: String, childID: String, index: Int32, handler: (error: OtsimoError) -> Void)
}

public protocol GameApi {
    func getGame(id: String, handler: (Game?, error: OtsimoError) -> Void)
    
    func getAllGames(handler: (Game?, done: Bool, error: OtsimoError) -> Void)
    
    func getGameRelease(id: String, version: String?, onlyProduction: Bool?, handler: (OTSGameRelease?, error: OtsimoError) -> Void)
    
}

public protocol CatalogApi {
    func getCatalog(handler: (OTSCatalog?, OtsimoError) -> Void)
}


