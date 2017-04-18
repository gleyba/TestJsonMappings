//
//  TestAppTests.swift
//  TestAppTests
//
//  Created by Gleb Kolobkov on 17/04/2017.
//
//

import XCTest
@testable import TestApp
import TestJsonToObjectMappings


class TestModel : NSObject {
    dynamic var id : Int = 0
    dynamic var Name : String = ""
    
    dynamic static func vsmbcRootClass() -> Class { return self }
}

class SwiftTests: XCTestCase {
    
    override func setUp() {
    
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
