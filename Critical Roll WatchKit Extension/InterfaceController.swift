//
//  InterfaceController.swift
//  Critical Roll WatchKit Extension
//
//  Created by Jake Winters on 2015-01-12.
//  Copyright (c) 2015 Jake Winters. All rights reserved.
//

import WatchKit
import Foundation
import RollKit


class InterfaceController: WKInterfaceController {
    
    @IBOutlet weak var dieTable: WKInterfaceTable!
    
    var dice: [Die] = []
    
    let rowType = "DieTableRowController"

    override init() {
        super.init()
        
        loadTableData()
    }

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    func loadTableData() {
        for dieType in DieType.allDice {
            dice += [Die(ofType: dieType)]
        }
        
        dieTable.setNumberOfRows(dice.count, withRowType: rowType)
        
        for (index, die) in enumerate(dice) {
            let dieRowController = dieTable.rowControllerAtIndex(index) as? DieTableRowController
            
            if dieRowController != nil {
                dieRowController!.dieNameLabel.setText(die.type.toString().uppercaseString)
            } else {
                NSLog("Cannot set die label at index \(index) of table. No row controller returned.")
            }
            
        }
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        return dice[rowIndex]
    }

}
