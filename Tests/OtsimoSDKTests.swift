//
//
//  Created by Sercan Değirmenci on 07/12/15.
//  Copyright © 2015 Otsimo. All rights reserved.
//

import XCTest
@testable import OtsimoSDK
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

    func testDiscovery() {
        let readyExpectation = expectation(description: "ready")

        Otsimo.configFromDiscoveryService("https://services.otsimo.xyz:30862", env: "staging",timeout:5) { cc in
            XCTAssertNotNil(cc, "Error")
            print("Otsimo.sharedInstance.cluster=\(Otsimo.sharedInstance.cluster.config)")
            // Perform our tests...
            // And fulfill the expectation...
            readyExpectation.fulfill()
            // Loop until the expectation is fulfilled
        }
        waitForExpectations(timeout: 5, handler: { error in
            XCTAssertNil(error, "Error")
        })
    }
    func testDiskStorageUrl() {
        let readyExpectation = expectation(description: "ready")

        Otsimo.configFromDiscoveryService("https://services.otsimo.com:30862", env: "production",timeout:5) { cc in
            XCTAssertNotNil(cc, "Error")
            XCTAssertNotEqual(Otsimo.sharedInstance.cluster.diskStorageUrl(), "")
            let correct = "https://services.otsimo.com:30851/public/1234/0_1_2/otsimo.json"
            XCTAssertEqual(Otsimo.sharedInstance.fixGameAssetUrl("1234", version: "0.1.2", rawUrl: "/otsimo.json"), correct)
            XCTAssertEqual(Otsimo.sharedInstance.fixGameAssetUrl("1234", version: "0.1.2", rawUrl: "otsimo.json"), correct)

            readyExpectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: { error in
            XCTAssertNil(error, "Error")
        })
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
