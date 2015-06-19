//
//  Die.swift
//  Critical Roll
//
//  Created by Jake Winters on 2014-11-16.
//  Copyright (c) 2014 Jake Winters. All rights reserved.
//

import Foundation

// TODO: Move into Die?
/// Limited enums values for each die type that is supported, from D4 to D00.
enum DieType: Int {
    
    /// Set Enum types and values.
    case D4 = 4, D6 = 6, D8 = 8, D10 = 10, D12 = 12, D20 = 20, D00 = 100
    
    /// A list of all die types as DieType.
    static let allDice = [DieType.D4, .D6, .D8, .D10, .D12, .D20, .D00]
    
    /// A list of all die types as String.
    static let allDiceStrings = ["d4", "d6", "d8", "d10", "d12", "d20", "d00"]
    
    /// Returns a DieType from String value.
    init?(fromString dieType: String) {
        switch dieType.lowercaseString {
        case "d4":
            self = D4
        case "d6":
            self = D6
        case "d8":
            self = D8
        case "d10":
            self = D10
        case "d12":
            self = D12
        case "d20":
            self = D20
        case "d00":
            self = D00
        default:
            return nil
        }
    }
    
    /// Convert String to DieType.
    ///
    /// :param: self The DieType enum in Enum form.
    /// :returns: returns a string of name (with a lowercase D).
    /// TODO: Remove switch, convert to "d\(toRaw)" or similar.
    func toString() -> String {
        switch self {
        case .D4:
            return "d4"
        case .D6:
            return "d6"
        case .D8:
            return "d8"
        case .D10:
            return "d10"
        case .D12:
            return "d12"
        case .D20:
            return "d20"
        case .D00:
            return "d00"
        }
    }
    
    func toString(forAmmount ammount: Int) -> String {
        return (ammount != 1) ? "\(ammount)\(self.toString())" : self.toString()
    }
}


/// An object representation of an n-sided die.
class Die {
    
    /// DieType of this specific die. A die must have a DieType, or it isn't a die.
    let type: DieType

    /// The upper bound of the Die.
    lazy var upperBound: UInt32 = {
        return UInt32(self.type.rawValue)
    }()
    
    /// The current value of the rolled die. Will start with a random value.
    var value = 0
    var secondaryValue = 0
    
    
    /// Creates a Die instance of DieType
    ///
    /// :param: ofType DieType of the type you are looking for.
    /// :returns: A Die of DieType.
    init(ofType dieType: DieType) {
        type = dieType
        value = self.roll()
    }
    
    /// Create a Die instance by string
    ///
    /// :param: ofType String representing a DieType.
    /// :returns: A Die of type given in String.
    convenience init?(ofType dieType: String) {
        if let type = DieType(fromString: dieType) {
            self.init(ofType: type)
        } else {
            self.init(ofType: .D4)
            return nil
        }
    }
    
    /// Generates a random Int value between 1 and upperBound (determined by DieType), stores it in value and returns it as well.
    ///
    /// :returns: Int Value between 1 and DieType.rawValue
    func roll() -> Int {
        value = Int( arc4random_uniform( upperBound ) ) + 1
        return value
    }
    
    /// Return true if the roll is a critcal miss (1).
    ///
    /// :returns: Bool True if the roll is a 1. False otherwise.
    func criticalMiss() -> Bool {
        return (1 == value) ? true : false
    }
    
    /// Return true if the roll is a critcal hit (upperBound of die).
    ///
    /// :returns: Bool True if the roll is a upperBound of die. False otherwise.
    func criticalHit() -> Bool {
        return (self.type.rawValue == value) ? true : false
    }
    
    /// Rolls two dice. Sets the value as the higher of the two, and the secondaryValue as the lower.
    ///
    /// :returns: Returns the value of the higher roll.
    func advantageRoll() -> Int {
        let value1 = roll()
        let value2 = roll()
        
        if value1 >= value2 {
            value = value1
            secondaryValue = value2
        } else {
            value = value2
            secondaryValue = value1
        }
        
        return value
    }
    
    /// Rolls two dice. Sets the value as the lower of the two, and the secondaryValue as the higher.
    ///
    /// :returns: Returns the value of the lower roll.
    func disadvantageRoll() -> Int {
        let value1 = roll()
        let value2 = roll()
        
        if value1 <= value2 {
            value = value1
            secondaryValue = value2
        } else {
            value = value2
            secondaryValue = value1
        }
        
        return value
    }    
}