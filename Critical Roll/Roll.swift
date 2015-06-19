//
//  Roll.swift
//  Critical Roll
//
//  Created by Jake Winters on 2014-11-13.
//  Copyright (c) 2014 Jake Winters. All rights reserved.
//

import Foundation
import CoreData


/// A group of Dice plus/minus a modifier.
@objc(Roll)
class Roll: NSManagedObject {

    // Mark: NSManaged Varibales
    @NSManaged var name: String
    @NSManaged var d4, d6, d8, d10, d12, d20, d00: NSNumber
    @NSManaged var modifier: NSNumber
    @NSManaged var highlight: Bool
    @NSManaged var character: PlayerCharacter?
    @NSManaged var uuid: String?
    
    var characterName: String {
        return character?.name ?? "No Character"
    }
    
    var rollDescription = ""
    
    // MARK: Instance Variables
    
    /// The current types of dice.
    var currentDiceTypes: [DieType] = []
    /// TODO: current die types?
    
    /// The actual Dice that will be rolled, sorted by type.
    var dice: [DieType : [Die]] = [:]
    
    /// The final value of the total roll (each dice plus any modifier).
    var total = 0
    
    var criticalHit = false
    var criticalMiss = false
    
    
    
    // MARK: - NSManagedObject Functions
    override func awakeFromFetch() {
        // Set dice when this object wakes.
        setDice()
    }
    
    override func awakeFromInsert() {
        // Set dice when this object wakes.
        setDice()
        
        self.uuid = NSUUID().UUIDString
    }
    
    override func setValue(value: AnyObject?, forKey key: String) {
        super.setValue(value, forKey: key)
        
        // Set dice when this object's dice are modified.
        setDice()
    }
    
    
    // MARK: - Dice Management Functions
    
    /// Set the number of dice for a specific die.
    ///
    /// :param: value Number of this type of die.
    /// :param: dieType String value for the type of die.
    func setValue(value: Int, forDie dieType: String) {
        setValue(value, forKey: dieType)
    }
    
    
    /// Set the number of dice for a specific DieType.
    ///
    /// :param: value Number of this type of die.
    /// :param dieType DieType of the type of die.
    func setValue(value: Int, forDie dieType: DieType) {
        setValue(value, forKey: dieType.toString())
    }
    
    
    /// Number of die for a specific DieType.
    ///
    /// :param: dieType DieType of die you are looking for the number of.
    /// :returns: Number of die of DieType.
    func numberOfDie(dieType: DieType) -> Int {
        return numberOfDie(dieType.toString()) ?? 0
    }
    
    
    /// Number of die for a specific die type.
    ///
    /// :param: dieType Type of die you are looking for the number of.
    /// :returns: Number of die of die type.
    func numberOfDie(dieType: String) -> Int {
        return valueForKey(dieType) as Int
    }
    
    
    
    /// Creates an dictionary of Die arrays, sorted by their DiceType.
    ///
    /// Takes the current DieTypes in use by this roll, and the number of dice for each type, and creates a dictionary of type 
    /// [DieType:[Die]] and stores it in the dice variable. Used for the roll() method, or for displaying.
    func setDice() {
        
        // Set dice as an empty dictionary.
        dice = [:]
        var diceNames: [String] = []
        
        // Ensure that currentDiceTypes has the latest types of dice.
        currentDiceTypes = D.allDice.filter { 0 != self.numberOfDie($0) }

        for dieType in currentDiceTypes {
            dice[dieType] = []
            
            let diceName = dieType.toString(forAmmount: numberOfDie(dieType))
            diceNames.append(diceName)
            
            for _ in 1...numberOfDie(dieType) {
                dice[dieType]!.append(Die(ofType: dieType))
            }
        }
        
        if modifier != 0 {
            diceNames.append("\(modifier)")
        }
        
        rollDescription = " + ".join(diceNames)
    }
    
    
    /// Generate a number based off the random results of the modifier, and the dice used to create the roll.
    ///
    /// Starts with the modifier, and then adds a unique result for every dice in use for this roll. The value
    /// is returned as Int, but is also stored in the total instance varibale. Sets the criticalHit or
    /// criticalMiss if all values are die.upperBound or 1 respectively.
    ///
    /// :returns: Value of the modifier plus each unique roll of the dice within this roll.
    func roll() -> Int {
        
        criticalHit = true
        criticalMiss = true
        
        total = Int(modifier)
        
        for (dieType, dieArray) in dice {
            for die in dieArray {
                
                
                total += die.roll()
                criticalHit  = criticalHit && die.criticalHit()
                criticalMiss = criticalMiss && die.criticalMiss()
            }
        }
        
        return total
    }
    
    
    class func insertInManagedObjectContext(context: NSManagedObjectContext) -> Roll {
        let entity = NSEntityDescription.entityForName("Roll", inManagedObjectContext: context)
        return NSEntityDescription.insertNewObjectForEntityForName(entity!.name!, inManagedObjectContext: context) as Roll
    }
    
    
    
    
    
    
    
    
    
    
    
    
}
