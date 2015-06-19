//
//  Character.swift
//  Critical Roll
//
//  Created by Jake Winters on 2014-12-23.
//  Copyright (c) 2014 Jake Winters. All rights reserved.
//

import Foundation
import CoreData

@objc(PlayerCharacter)
class PlayerCharacter: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var rolls: NSSet
    @NSManaged var uuid: String?

    
    func handleContextDidChangeNotification(notification: NSNotification) {
    }
    
    override func awakeFromInsert() {
        self.uuid = NSUUID().UUIDString
    }
    
}
