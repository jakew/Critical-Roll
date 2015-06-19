//
//  DieTests.swift
//  Critical Roll
//
//  Created by Jake Winters on 2014-12-06.
//  Copyright (c) 2014 Jake Winters. All rights reserved.
//

import UIKit
import XCTest

class DieTests: XCTestCase {
    
    let d4 = Die(ofType: .D4)
    let d00 = Die(ofType: .D00)

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInitialization() {
        // Test creation of a D4 using DieType.
        let d4 = Die(ofType: .D4)
        XCTAssertEqual(d4.type, DieType.D4, "Die initialization of DieType.D4 did not return a .D4 Die.")
        
        // Test creation of a D6 using string.
        let d6 = Die(ofType: "d6")
        XCTAssertEqual(d6!.type, DieType.D6, "Die initialization of string \"d6\" did not return a D6 Die.")
        
        // Test creation of a D8 using a capitalized string.
        let d8 = Die(ofType: "D8")
        XCTAssertEqual(d8!.type, DieType.D8, "Die initialization of string \"D8\" did not return a .D8 Die.")
        
        // Test that the Die of type D9 returns nil.
        let d7 = Die(ofType: "d9")
        XCTAssertNil(d7, "Die initialization of string \"d9\" is not nil.")
    }
    
    func testUpperBounds() {
        // Test the upper bound of a D4, should be 4.
        XCTAssertEqual(d4.upperBound, UInt32(4), "Incorrect upperBound for the Die of type .D4. It should be 4 but is not.")
        
        // Test the upper bound of a D00, should be 100.
        XCTAssertEqual(d00.upperBound, UInt32(100), "Incorrect upperBound for the Die of type .D4. It should be 4 but is not.")
    }
    
    
    func testDieReturnValues() {
        for _ in 1...100 {
            let i = self.d4.roll()
            XCTAssertGreaterThanOrEqual(i, 0, "The roll was less than 1.")
            XCTAssertLessThanOrEqual(i, Int(self.d4.upperBound), "The roll was greater than the upperBound.")
        }
    }
    
    // Can this be usefull for anything?
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
            
            for _ in 1...100 {
                self.d4.roll()
            }
        }
    }

}
