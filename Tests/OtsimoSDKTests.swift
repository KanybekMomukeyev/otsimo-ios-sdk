//
//  AccountSDKTests.swift
//  AccountSDKTests
//
//  Created by Sercan Değirmenci on 07/12/15.
//  Copyright © 2015 Otsimo. All rights reserved.
//

import XCTest
import OtsimoApiGrpc
import OtsimoSDK
import Haneke

class OtsimoSDKTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let expectation = expectationWithDescription("...")
        
        let cache = Shared.JSONCache
        let URL = NSURL(string: "http://192.168.99.100:18851/public/56b24d99656c7c000160018c/0_0_1/settings.json")!
        
        cache.fetch(URL: URL).onSuccess {JSON in
            if let prop = JSON.dictionary?["properties"] as? [String : [String : AnyObject]] {
                for (k, v) in prop {
                    print(k, v["id"]!)
                }
            } else {
                XCTFail("failed to get properties object")
            }
            expectation.fulfill()
        }.onFailure {e in
            XCTFail("failed to fetch \(e)")
        }
        
        waitForExpectationsWithTimeout(10) {error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func testKV() {
        let expectation = expectationWithDescription("...")
        
        let URL = NSURL(string: "http://192.168.99.100:18851/public/56b8a5583ee0720001d128ee/0_0_1/i18n/kv/tr.json")!
        GameKeyValueStore.fromUrl(URL) {kv, e in
            if let kv = kv {
                XCTAssertEqual("Orta", kv.settingsTitle("difficulty", enumKey: "medium"))
                XCTAssertEqual(23, kv.integer("test_integer"))
                XCTAssertEqual(123.23, kv.float("test_float"))
                let ia = kv.any("test_int_array") as! [Int]
                XCTAssertEqual(ia.count, 2)
                XCTAssertTrue(ia.contains(23))
                XCTAssertTrue(ia.contains(123))
                let dd = kv.any("test_object") as! [String: AnyObject]
                XCTAssertEqual(dd.count, 2)
                
                expectation.fulfill()
            } else {
                XCTFail("failed to fetch \(e)")
            }
        }
        
        waitForExpectationsWithTimeout(10) {error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
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
