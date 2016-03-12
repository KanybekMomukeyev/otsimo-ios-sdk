//
//
//  Created by Sercan Değirmenci on 07/12/15.
//  Copyright © 2015 Otsimo. All rights reserved.
//

import XCTest
import OtsimoApiGrpc
import OtsimoSDK
import Locksmith

class OtsimoSDKTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testOtsimoAccount() {
        struct OtsimoAccount: ReadableSecureStorable, CreateableSecureStorable, DeleteableSecureStorable, GenericPasswordSecureStorable {
            let email: String
            let password: String
            let service = "Otsimo"
            let jwt = "hellyeah"
            var account: String { return email }

            var data: [String: AnyObject] {
                return ["password": password, "jwt": jwt]
            }
        }

        let account = OtsimoAccount(email: "kl@otsimo.com", password: "my_password")

        // CreateableSecureStorable lets us create the account in the keychain
        try! account.createInSecureStore()
        try! account.createInSecureStore()

        // ReadableSecureStorable lets us read the account from the keychain
        let account2 = OtsimoAccount(email: "kl@otsimo.com", password: "fuck")
        let result = account2.readFromSecureStore()

        print("iOS app: \(result),", "\ndata:\n", "\(result?.data)", "\n")

        // DeleteableSecureStorable lets us delete the account from the keychain
        try! account.deleteFromSecureStore()
    }

    /*
     func testPerformanceExample() {
     // This is an example of a performance test case.
     self.measureBlock {
     // Put the code you want to measure the time of here.
     }
     }
     */
}
