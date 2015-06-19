//
//  RollTests.swift
//  Critical Roll
//
//  Created by Jake Winters on 2014-12-07.
//  Copyright (c) 2014 Jake Winters. All rights reserved.
//

import UIKit
import CoreData
import XCTest


// TODO: Clean up these tests.
class RollTests: ManagedObjectTests {
    
    lazy var roll: Roll = self.mockRoll()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        if managedObjectContext == nil {
            XCTFail("Managed Object Context not created.")
            abort()
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    

    // Test that we can create a roll object.
    func testCreateARoll() {
        
        // Create a new roll using the standard method.
        let object1: AnyObject? = NSEntityDescription.insertNewObjectForEntityForName("Roll", inManagedObjectContext: self.managedObjectContext!)
        let roll1 = object1 as Roll
        
        // Create a new roll using the convenience method.
        let roll2 = Roll.insertInManagedObjectContext(self.managedObjectContext!)
        
        XCTAssertNotNil(roll1, "roll1 is nil, when it should not be.")
        XCTAssertNotNil(roll2, "roll2 is nil, when it should not be.")
        
        var error: NSError?
        if ( !managedObjectContext!.save(&error) ) {
            XCTFail("Error saving in \"\(__FUNCTION__)\": \(error), \(error?.userInfo)")
        } else {
            XCTAssert(true, "Creating a Roll did not create an error.")
        }
    }
    
    
    
    // Test the description of a roll.
    func testRollDescription() {
        XCTAssertEqual(roll.rollDescription, "2d4 + 3d6 + 4d8 + 5d10 + 6d12 + 7d20 + 8d00 + 1")
    }
    
    
    
    // Test the currentDice of a roll matches the ammount of each type of dice.
    func testCurrentDiceOfRoll() {
        // Create a roll w/ verying number of dice.
        let dice = roll.dice
        XCTAssertEqual(roll.currentDiceTypes, DieType.allDice, "The roll does not have the correct dice types.")
        
        var i = 2
        
        for dieType in DieType.allDice {
            XCTAssertEqual(dice[dieType]!.count, i++, "The die did not have the correct value.")
        }
    }
    
//    func testConvenienceMethods() {
//        roll.setValue(3, forDie: "d6")
//        roll.setValue(2, forDie: .D4)
//        
//        XCTAssertEqual(roll.numberOfDie(.D6), 3, "D6 should now have a count of 3.")
//        XCTAssertEqual(roll.numberOfDie("d4"), 2, "D4 should now have a count ")
//    }
    
    
    // MARK: - Integration Testing
    
    // Test the criticalHit and the min roll value are correct using Loaded Dice.
    func testCriticalHit() {
        roll.dice = loadDice(roll.dice, maxAmmount: true)
        
        XCTAssertEqual(roll.roll(), 1121, "The max value of the roll does not equal the max sum of the dice + the modifier.")
        XCTAssertTrue(roll.criticalHit, "Roll should be a critical hit, but it is not.")
        XCTAssertFalse(roll.criticalMiss, "Roll should not be a critical miss, but it is.")
    }

    // Test the criticalMiss and the min roll value are correct using Loaded Dice.
    func testCriticalMiss() {
        roll.dice = loadDice(roll.dice, maxAmmount: false)
        
        XCTAssertEqual(roll.roll(), 36, "The max value of the roll does not equal the max sum of the dice + the modifier.")
        XCTAssertTrue(roll.criticalMiss, "Roll should be a critical miss, but it is not.")
        XCTAssertFalse(roll.criticalHit, "Roll should not be a critical hit, but it is.")
    }
    
    
    
    
    // MARK: - Functions to assist with testing.
    
    /// Generates a mock Roll for use with testing Rolls.
    ///
    /// :return: The Roll created with those parameters.
    func mockRoll() -> Roll {
        let roll = Roll.insertInManagedObjectContext(managedObjectContext!)
        
        roll.name = "Mock Roll"
        roll.modifier = 1
        roll.d4 = 2
        roll.d6 = 3
        roll.d8 = 4
        roll.d10 = 5
        roll.d12 = 6
        roll.d20 = 7
        roll.d00 = 8
        roll.setDice()
        
        return roll
    }
    
    func loadDice(realDice: [DieType: [Die]], maxAmmount max: Bool) -> [DieType: [Die]] {
        
        var loadedDice: [DieType: [Die]] = [:]
        for (dieType, dice) in realDice {
            loadedDice[dieType] = []
            for _ in dice {
                var die = LoadedDie(ofType: dieType)
                die.max = max
                loadedDice[dieType]!.append(die)
            }
        }
        return loadedDice
    }

}
