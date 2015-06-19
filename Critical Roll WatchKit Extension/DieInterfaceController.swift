//
//  DieInterfaceController.swift
//  Critical Roll
//
//  Created by Jake Winters on 2015-01-13.
//  Copyright (c) 2015 Jake Winters. All rights reserved.
//

import WatchKit
import Foundation
import RollKit


class DieInterfaceController: WKInterfaceController {
    
    var die: Die!
    
    
    @IBOutlet weak var resultLabel: WKInterfaceLabel!
    @IBOutlet weak var rollButton: WKInterfaceButton!
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        self.die = context as! Die
        
        self.rollButton.setTitle("Roll \(self.die.type.toString().uppercaseString)")
        
        self.rollDie()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    @IBAction func rollDie() {
        die.roll()
        resultLabel.setText("\(die.value)")
        
        if die.criticalHit() {
            resultLabel.setTextColor(UIColor.redColor())
        } else if die.criticalMiss() {
            resultLabel.setTextColor(UIColor.blueColor())
        } else {
            resultLabel.setTextColor(UIColor.whiteColor())
        }
    }
    
}
