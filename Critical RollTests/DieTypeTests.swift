//
//  DieTypeTests.swift
//  Critical Roll
//
//  Created by Jake Winters on 2014-12-01.
//  Copyright (c) 2014 Jake Winters. All rights reserved.
//

import UIKit
import XCTest

class DieTypeTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testNumberOfDiceTypes() {
        XCTAssertEqual(DieType.allDice.count, 7, "There are not 7 types of DieType listed in DieType.allDice.")
        XCTAssertEqual(DieType.allDiceStrings.count, 7, "There are not 7 type Strings listedi n DieType.allDiceStrings.")
    }
    
    func testDieTypeFromString() {
        
        // Are we able to creating one?
        var dieTypeD4 = DieType(fromString: "d4")
        XCTAssertEqual(DieType.D4, dieTypeD4!, "The dice returend by \"d4\" should be a DieType.D4.")
        
        // Do capitals matter?
        let dieTypeD6 = DieType(fromString: "D6")!
        XCTAssertEqual(DieType.D6, dieTypeD6, "The dice returend by \"d6\" should be a DieType.D4.")
        
        // Can we mistakenly create one?
        if let die = DieType(fromString: "d9") {
            XCTFail("DieType for d9 was not nil.")
        }
    }
    
    func testDieTypeToString() {
        
        // Does a .D4 return "d4"?
        var dieTypeD4 = DieType.D4
        XCTAssertEqual(dieTypeD4.toString(), "d4", "The D4 die did not return a string of \"d4\".")
        
        // Does a .D4 return "d00"?
        var dieTypeD00 = DieType.D00
        XCTAssertEqual(dieTypeD00.toString(), "d00", "The D00 die did not return a string of \"d00\".")

    }
    
    func testDieTypeToStringForAmmount() {
        
        // Does a .D4 return "d4"?
        var dieTypeD4 = DieType.D4
        XCTAssertEqual(dieTypeD4.toString(forAmmount: 1), "d4", "The single D4 die did not return a string of \"d4\".")
        
        // Does a .D4 return "d00"?
        var dieTypeD00 = DieType.D00
        XCTAssertEqual(dieTypeD00.toString(forAmmount: 2), "2d00", "The 2 D00 die did not return a string of \"2d00\".")
        
    }
}
