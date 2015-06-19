//
//  RollViewController.swift
//  Critical Roll
//
//  Created by Jake Winters on 2014-11-13.
//  Copyright (c) 2014 Jake Winters. All rights reserved.
//

import UIKit
import CoreData

/// A custom view used to control the details Roll view.
class RollViewController: UIViewController {

    /// The label that shows the total Roll value.
    @IBOutlet weak var rollTotalLabel: UILabel!
    
    /// The label that shows the name of the Roll.
    @IBOutlet weak var rollNameLabel: UILabel!

    /// The Roll that we are displaying.
    var roll: Roll? {
        didSet {
            if self.roll != nil {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleContextDidChangeNotification:"), name: NSManagedObjectContextObjectsDidChangeNotification, object: nil)
            } else {
                NSNotificationCenter.defaultCenter().removeObserver(self)
            }
        }
    }
    
    // MARK: - UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        
        // Configure UserActivity
        self.userActivity = NSUserActivity(activityType: AppDelegate.ActivityTypes.viewingRollActivityType)
    }
    
    override func viewWillAppear(animated: Bool) {
        // setup userActivity
        userActivity?.becomeCurrent()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.userActivity?.invalidate()
        self.userActivity = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Handoff methods
    
    override func updateUserActivityState(activity: NSUserActivity) {
        if roll == nil {
            return
        }
        
        let rollURIKey = AppDelegate.ActivityTypes.rollURI
        
        activity.title = "View Roll"
        activity.addUserInfoEntriesFromDictionary([rollURIKey : roll!.uuid!])
    }
    
    
    // MARK: RollViewController Methods
    
    // TODO: This needs to be called when the Roll is updated from Core Data.
    /// Function called when the view needs to be configured to display the Roll.
    func configureView() {
        // Update the user interface for the detail item.
        if let roll: Roll = self.roll {
            self.rollNameLabel.text = roll.name
            self.rollTotalLabel.text = "\(roll.total)"
        }
    }
    
    
    /// Roll the roll, and then put the result into the rollTotalLabel above.
    ///
    /// :param: sender The object calling the method. Usually a bar button.
    /// TODO: Make this "roll" the numbers, as well.
    @IBAction func rollDie(sender: UIButton) {
        if let roll: Roll = self.roll {
            
            self.rollTotalLabel.textColor = UIColor.blackColor()
            self.rollTotalLabel.text = "\(roll.roll())"
            
            if roll.highlight {
                
                if roll.criticalHit {
                    self.rollTotalLabel.textColor = UIColor.redColor()
                } else if roll.criticalMiss {
                    self.rollTotalLabel.textColor = UIColor.blueColor()
                }
                
            }
            
        }
    }


    /// Pulls up the EditRollViewController so that the user can modifiy the roll.
    ///
    /// :param: sender The object calling the method. Usually a bar button.
    @IBAction func displayEditRollViewControllerModal(sender: UIBarButtonItem) {
        
        let storyboard = UIStoryboard(name: "EditRoll", bundle: nil)
        let navigationController = storyboard.instantiateViewControllerWithIdentifier("InitialController") as UINavigationController
        let editController = navigationController.topViewController as EditRollViewController
        
        if let roll = self.roll {
            editController.setRollFromContext(roll.managedObjectContext!, andObjectID: roll.objectID) {
                (roll: Roll?) -> Void in
                self.configureView()
            }
        }
        
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    
    // This function is driving me crazy...
    func handleContextDidChangeNotification(notification: NSNotification) {
        NSLog("Currently drawing the view for \(roll?.name)")
        self.configureView()
    }
}

