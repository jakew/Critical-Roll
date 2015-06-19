//
//  LoadedDie.swift
//  Critical Roll
//
//  Created by Jake Winters on 2014-12-09.
//  Copyright (c) 2014 Jake Winters. All rights reserved.
//

import Foundation

class LoadedDie: Die {
    
    /// True for max value, false for 1.
    var max = true
    
    /// A Die that only returns type 1 or max value.
    override func roll() -> Int {
        value = (max) ? self.type.rawValue : 1
        return value
    }
    
}