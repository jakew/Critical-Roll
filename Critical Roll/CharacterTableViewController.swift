//
//  CharacterTableViewController.swift
//  Critical Roll
//
//  Created by Jake Winters on 2014-12-23.
//  Copyright (c) 2014 Jake Winters. All rights reserved.
//

import UIKit
import CoreData

class CharacterTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // Create own ManagedOjectContaxt
    // Pass Character's ID.
    // Pass Block that takes Character's ID, and returns void.
    var selectedCharacter: PlayerCharacter? = nil
    var completion: ((PlayerCharacter?)->Void)?
    
    var managedObjectContext: NSManagedObjectContext? = nil
    
    //var selectedCharacter: PlayerCharacter? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tableView.allowsSelectionDuringEditing = true
    }
    

    // MARK: - NSFetchedResultsControllerDelegate methods
    
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        
        let entity = NSEntityDescription.entityForName("PlayerCharacter", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchBatchSize = 0
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master2")
        aFetchedResultsController.delegate = self
        
        _fetchedResultsController = aFetchedResultsController
        
        var error: NSError? = nil
        if !_fetchedResultsController!.performFetch(&error) {
            abort()
        }
        
        return _fetchedResultsController!
    }
    
    
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                // Configure Cell
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
    
    
    
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects + 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let sectionInfo = self.fetchedResultsController.sections![indexPath.section] as NSFetchedResultsSectionInfo
        
        if indexPath.row == sectionInfo.numberOfObjects {
            let cell = tableView.dequeueReusableCellWithIdentifier("NewCharacterCell", forIndexPath: indexPath) as UITableViewCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("CharacterCell", forIndexPath: indexPath) as UITableViewCell
            self.configureCell(cell, atIndexPath: indexPath)
            return cell
        }
    }
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let sectionInfo = self.fetchedResultsController.sections![indexPath.section] as NSFetchedResultsSectionInfo
        if sectionInfo.numberOfObjects > indexPath.row {
            return true
        }
        return false
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as PlayerCharacter)
            
            var error: NSError? = nil
            if !context.save(&error) {
                NSLog("Unresolved error \(error), \(error?.userInfo)")
                abort()
            }
        }
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let sectionInfo = self.fetchedResultsController.sections![indexPath.section] as NSFetchedResultsSectionInfo
        
        if indexPath.row == sectionInfo.numberOfObjects {
            return
        }
        
        // TODO: Correct this warning?
        let character = self.fetchedResultsController.objectAtIndexPath(indexPath) as PlayerCharacter
        
        selectedCharacter = (selectedCharacter != character) ? character : nil
        
        if completion != nil {
            completion!(selectedCharacter)
        }
        
        self.tableView.reloadData()
    }
    
    
    
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        return (identifier == "showEditCharacter") ? tableView.editing : true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showEditCharacter" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                
                let characterToPass = self.fetchedResultsController.objectAtIndexPath(indexPath) as PlayerCharacter
                let controller = segue.destinationViewController as EditCharacterViewController
                controller.character = characterToPass as PlayerCharacter
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        } else if segue.identifier == "showNewCharacter" {
            
            // TODO: Move into new controller?
            let context = self.fetchedResultsController.managedObjectContext
            let entity = self.fetchedResultsController.fetchRequest.entity!
            
            let characterToPass = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context) as PlayerCharacter
            characterToPass.name = "Character \(NSDate())"
            
            let controller = segue.destinationViewController as EditCharacterViewController
            controller.character = characterToPass as PlayerCharacter
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }
    
    
    // MARK: - CharacterTableViewController methods

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let character = self.fetchedResultsController.objectAtIndexPath(indexPath) as PlayerCharacter
        
        if character == selectedCharacter {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        cell.textLabel!.text = character.name
    }
    
     @IBAction func insertCharacter(sender: NSObject) {
        let context = self.fetchedResultsController.managedObjectContext
        let entity = self.fetchedResultsController.fetchRequest.entity!
        var error: NSError? = nil
        
        let character = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context) as PlayerCharacter
        NSLog("Entity name is \(entity.name!)")
        character.name = "Character \(NSDate())"
        
        if !context.save(&error) {
            NSLog("Unresolved error \(error), \(error?.userInfo)")
            abort()
        }
        
    }
    
    // TODO: COnvert to Character instead of Character ID?
    func setControllerWithContext(context: NSManagedObjectContext, characterObjectID: NSManagedObjectID?, completion aCompletion: (PlayerCharacter?)->()) {
        self.managedObjectContext = context
        
        if characterObjectID != nil {
            selectedCharacter = self.managedObjectContext?.existingObjectWithID(characterObjectID!, error: nil) as? PlayerCharacter
        }
        
        self.completion = aCompletion
    }
}
