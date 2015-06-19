//
//  CriticalRollCoordinator.swift
//  Critical Roll
//
//  Created by Jake Winters on 2015-01-01.
//  Copyright (c) 2015 Jake Winters. All rights reserved.
//

import Foundation
import CoreData


/**
    The CriticalRollCoordinatorDelegate is used to standardize the way in which the Critical Roll Coordinator communicates back to the AppDelegate that created it.
*/
protocol CriticalRollCoordinatorDelegate {
    mutating func promptUserForStorageOption()
    mutating func notifyUserOfAccountChange()
}

class CriticalRollCoordinator: NSObject {
    
    // MARK: Types
    
    /**
        String constants used for saving properties in UserDefaults, or for iCloud containers
    */
    private struct Defaults {
        
        /// String constant to check if this is the first launch.
        // TODO: Confirm if still necessary.
        static let firstLaunchKey = "CriticalRollCoordinator.Defaults.firstLaunchKey"
        
        /// String constant to check if the storage type set.
        static let storageOptionKey = "CriticalRollCoordinator.Defaults.storageOptionKey"
        
        /// String constant token used for iCloud.
        static let storedUbiquityIdentityToken = "Critical-Roll~Cloud~Documents"
    }


    /**
        The possible options for storage.
    
        - Not Set (default)
        - Local
        - Cloud
    */
    enum StorageType: Int {
        case NotSet = 0, Local, Cloud
    }
    
    
    
    // MARK: Regular Properties
    
    
    /// The delegate
    var delegate: CriticalRollCoordinatorDelegate? = nil
    
    
    
    
    // MARK: Computed Properties
    
    
    /**
        Type of storage used, stored in UserDefaults.
    
        :returns: StorageType
    */
    var storageType: StorageType {
        get {
            let rawValue = NSUserDefaults.standardUserDefaults().integerForKey(Defaults.storageOptionKey)
            return StorageType(rawValue: rawValue)!
        }
        set {
            NSUserDefaults.standardUserDefaults().setInteger(newValue.rawValue, forKey: Defaults.storageOptionKey)
        }
    }
    
    
    //
    
    // Obtain URL for documents directory.
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
    }()
    
    // Obtain Managed Object Model
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("Critical_Roll", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    
    // Obtain the Persistant Store Coordinator
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Critical_Roll.sqlite")
        var options: [NSObject: AnyObject]? = nil
        var error:NSError? = nil
        
        if self.storageType == .Cloud {
            NSLog("User has opted for cloud.")
            options = [NSPersistentStoreUbiquitousContentNameKey: Defaults.storedUbiquityIdentityToken]
        }
        
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options, error: &error) == nil {
            
            coordinator = nil
            
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initalize the application's save data"
            dict[NSLocalizedFailureReasonErrorKey] = "There was an error creating or loading the application's saved data."
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)

            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        var moc: NSManagedObjectContext? = nil
        
        if let coordinator = self.persistentStoreCoordinator {
            moc = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            moc!.persistentStoreCoordinator = coordinator
        }
        
        return moc
    }()
    
    
    
    
    override init() {
        super.init()
        
        // Set Notificaitons
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handlePersistentStoreCoordinatorStoresWillChangeNotification:"), name: NSPersistentStoreCoordinatorStoresWillChangeNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handlePersistentStoreDidImportUbiquitousContentChangesNotification:"), name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: self.managedObjectContext!.persistentStoreCoordinator)
    }
    
    
    func saveContext() {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                NSLog("Unresolved error \(error). \(error!.userInfo)")
                abort()
            }
        }
    }
    
    
    // MARK: - Notification Handling methods
    
    func handlePersistentStoreCoordinatorStoresWillChangeNotification(notifiication: NSNotification) {
        self.managedObjectContext?.performBlock() {
            NSLog("Checking for changes.")
            
            var error: NSError? = nil
            
            if self.managedObjectContext!.hasChanges {
                NSLog("Changes found.")
                var saveError: NSError? = nil
                if !self.managedObjectContext!.save(&saveError) {
                    NSLog("Error saving information: \(saveError), \(saveError!.userInfo)")
                } else {
                    self.managedObjectContext!.reset()
                }
            }
            
            
        }
    }
    
    func handlePersistentStoreDidImportUbiquitousContentChangesNotification(notification: NSNotification) {
        self.managedObjectContext!.performBlock() {
            dispatch_async(dispatch_get_main_queue()) {
                self.managedObjectContext!.mergeChangesFromContextDidSaveNotification(notification)
                
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}



















