//
//  RollTableViewController.swift
//  Critical Roll
//
//  Created by Jake Winters on 2014-11-13.
//  Copyright (c) 2014 Jake Winters. All rights reserved.
//

import UIKit
import CoreData

/// Controller for the List of Rolls
class RollTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    // MARK: RollTableViewController Instance Variables
    var rollViewController: RollViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    
    var handoffIndexRedirect: NSIndexPath? = nil

    
    
    // MARK: - NSObject methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // If is iPad, start with an empty view at first.
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }
    
    // Important steps for use with multiple NSFetchedResultsController
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.fetchedResultsController.delegate = self
        self.fetchedResultsController.performFetch(nil)
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let handoffRedirect = handoffIndexRedirect {
            self.tableView.selectRowAtIndexPath(handoffRedirect, animated: true, scrollPosition: .None)
            
            self.performSegueWithIdentifier("showDetail", sender: nil)
            handoffIndexRedirect = nil
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.fetchedResultsController.delegate = nil
        NSFetchedResultsController.deleteCacheWithName("Master")
    }
 
    
    
    // MARK: - UIViewController methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set left button on UINavigationBar as the edit button.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        
        // TODO: Move to StoryBoard.
        //--
        // Create a add button.
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        
        // Set the leftBarButton as the Add Button.
        self.navigationItem.rightBarButtonItem = addButton
        //--
        
        // If is currently a split view (iPad/iPhone6+)
        if let split = self.splitViewController {
            
            // Get the RollViewController (Top View Controller of the right top split view panel.)
            let controllers = split.viewControllers
            self.rollViewController = controllers[controllers.count-1].topViewController as? RollViewController
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let roll = self.fetchedResultsController.objectAtIndexPath(indexPath) as Roll
                let controller = (segue.destinationViewController as UINavigationController).topViewController as RollViewController
                controller.roll = roll
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        
        if let sectionName = sectionInfo.name {
            return (sectionName.isEmpty) ? "No Character" : sectionName
        } else {
            return "No Character"
        }
    }
    
    // MARK: - UITableViewDataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath
        indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject)
                
            var error: NSError? = nil
            if !context.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                println("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }

    
    
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    // Storage for the temporary NSFetchedResultsController.
    // TODO: Review, maybe move to top?
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    
    /// Create and set the fetched results controller.
    // TODO: Review, maybe move to top?
    var fetchedResultsController: NSFetchedResultsController {
        
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Roll", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
//        let sortDescriptorCharacter = NSSortDescriptor(key: "character", ascending: false)
        let sortDescriptorName = NSSortDescriptor(key: "name", ascending: false)
        let sortDescriptors = [sortDescriptorName]//[sortDescriptorCharacter, sortDescriptorName]
        
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: "characterName", cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
    	var error: NSError? = nil
    	if !_fetchedResultsController!.performFetch(&error) {
    	     // Replace this implementation with code to handle the error appropriately.
    	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             //println("Unresolved error \(error), \(error.userInfo)")
    	     abort()
    	}
        
        return _fetchedResultsController!
    }
    
    
    // Table Update Methods
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        NSLog("RollTableView is updating section.")
        switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    
    
    
    // MARK: - RollTableViewController methods
    
    // TODO: Review this method. Possibly simply, and add into Roll class, or RollEditViewController?
    //       Possibly, the RollEditViewController can create a new instance, so Cancel removes the "new" Roll.
    
    /// Create a new instance of a Roll, and add it to the TableView.
    ///
    /// :param: sender The Object that submitted the request for a new Roll.
    func insertNewObject(sender: AnyObject) {
        
        // Create a local reference for the current CoreData context and entry, and create a nil error.
        let context = self.fetchedResultsController.managedObjectContext
        let entity = self.fetchedResultsController.fetchRequest.entity!
        var error: NSError? = nil
        
        // Create a new ManagedObject, and typeset it as a Roll.
        let roll = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context) as Roll
        // Basic configuraiton for the new roll:
        // Set the name.
        roll.name = "New Roll"
        
        // Attempt to save save the context.
        if !context.save(&error) {
            // TODO: Proper handling of the inabiltiy to save the context.
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
    }
    
    // MARK: - Handoff
    override func restoreUserActivityState(activity: NSUserActivity) {
        if let rollUUID = activity.userInfo![AppDelegate.ActivityTypes.rollURI] as? String {
            
            dispatch_async(dispatch_get_main_queue()) {
                
                if self.managedObjectContext == nil {
                    println("Managd Object Context not found when continuing roll on new device.")
                    return
                }
                
                var error: NSError? = nil
                
                
                let fetchRequest = NSFetchRequest(entityName: "Roll")
                fetchRequest.predicate = NSPredicate(format: "uuid == %@", rollUUID)
                
                let objects = self.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
                
                if error != nil {
                    NSLog("Error saving information: \(error), \(error!.userInfo)")
                    return
                }
                
                if let continueRoll = objects?.first {
                    self.handoffIndexRedirect = self.fetchedResultsController.indexPathForObject(objects!.first!)
                    self.tableView.selectRowAtIndexPath(self.handoffIndexRedirect, animated: true, scrollPosition: .None)
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }
                
                
            }
            
        }
    }
    
    
    /// Configures the view of a cell according to the Roll it represents.
    ///
    /// :param: cell The cell that needs to be configured.
    /// :param: indexPath The indexPath of the roll we are trying to display.
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        
        // Obtain the roll according to the indexPath through the Fetched Results Controller
        let roll = self.fetchedResultsController.objectAtIndexPath(indexPath) as Roll
        
        // Set the cell's text as the roll name.
        cell.textLabel!.text = roll.name
        
        // TODO: Add description of roll.
        cell.detailTextLabel!.text = roll.rollDescription
        
    }
}