
//
//  AppDelegate.swift
//  Critical Roll
//
//  Created by Jake Winters on 2014-11-13.
//  Copyright (c) 2014 Jake Winters. All rights reserved.
//

import UIKit
import CoreData
import Foundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate, CriticalRollCoordinatorDelegate {
    
    // Handoff static keys
    struct ActivityTypes {
        static let viewingRollActivityType = "ca.jakew.Critical-Roll.viewing.roll"
        static let rollURI = "ca.jakew.Critical-Roll.roll.uri"
    }

    
    var window: UIWindow?
    
    lazy var coordinator: CriticalRollCoordinator = {
        var coordinator = CriticalRollCoordinator()
        coordinator.delegate = self
        return coordinator
    }()
    
    
    
    var masterViewController: RollTableViewController? = nil

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Setup defaults.
        loadDefaultPreferences()
        
        
        // Override point for customization after application launch.
        // Setup Tab Bar controller
        let tabBarController = self.window!.rootViewController as UITabBarController
        
        // Tab 1
        // Setup Split View Controller
        let splitViewController = tabBarController.viewControllers!.first! as UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as UINavigationController
        navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        splitViewController.delegate = self
        splitViewController.preferredDisplayMode = .AllVisible

        let masterNavigationController = splitViewController.viewControllers[0] as UINavigationController
        let controller = masterNavigationController.topViewController as RollTableViewController
        controller.managedObjectContext = self.coordinator.managedObjectContext
        
        masterViewController = controller
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.coordinator.saveContext()
    }

    // MARK: - Split view

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController!, ontoPrimaryViewController primaryViewController:UIViewController!) -> Bool {
        if let secondaryAsNavController = secondaryViewController as? UINavigationController {
            if let topAsDetailController = secondaryAsNavController.topViewController as? RollViewController {
                if topAsDetailController.roll == nil {
                    // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
                    return true
                }
            }
        }
        return false
    }
    
    
    // MARK: - Handoff continuation
    
    func application(application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        println("Calling things")
        return true
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]!) -> Void) -> Bool {
        
        println("Launching with \(userActivity.userInfo!.debugDescription)")
        restorationHandler([masterViewController!])
        
        return true
    }

    
    
    // MARK: - Critical Roll methods
    
    func loadDefaultPreferences() {
        if let path = NSBundle.mainBundle().pathForResource("Preferences", ofType: "plist") {
            NSUserDefaults.standardUserDefaults().registerDefaults(NSDictionary(contentsOfFile: path)!)
        }
        
    }
    
    
    // MARK: - Critical Roll Coordinator Delegate methods
    
    func promptUserForStorageOption() {
        NSLog("Creating alert to prompt user.")
        
        let title = "Choose Storage Option"
        let message = "Do you want to store documents in iCloud or only in this device?"
        let localOnlyActionTitle = "Local Only"
        let cloudActionTitle = "iCloud"
        
        let storageRequestController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let localOption = UIAlertAction(title: localOnlyActionTitle, style: .Default) {
            localAction in
            self.coordinator.storageType = .Local
        }
        
        storageRequestController.addAction(localOption)
        
        let cloudOption = UIAlertAction(title: cloudActionTitle, style: .Default) {
            localAction in
            self.coordinator.storageType = .Cloud
        }
        
        storageRequestController.addAction(cloudOption)
        masterViewController?.navigationController!.presentViewController(storageRequestController, animated: true, completion: nil)
    }
    
    func notifyUserOfAccountChange() {
        let title = "Signed Out of iCloud"
        let message = "The iCloud account previosuly used with this App is no longer available. Please sign back in with that account to access the previous contents."
        let okActionTitle = "OK"
        
        let signedOutController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let action = UIAlertAction(title: okActionTitle, style: .Cancel, handler: nil)
        
        masterViewController?.navigationController!.presentViewController(signedOutController, animated: true, completion: nil)
    }
}
