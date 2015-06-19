//
//  EditRollViewController.swift
//  Critical Roll
//
//  Created by Jake Winters on 2014-11-13.
//  Copyright (c) 2014 Jake Winters. All rights reserved.
//

import UIKit
import CoreData


// TODO: Make this class presentable.
class EditRollViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    /// The Roll we are editing.
    var roll: Roll?
    var completion: ((Roll?)->())?
    
    
    // MARK: - UIViewController methods
    override func viewDidLoad() {
        let nib = UINib(nibName: "TextFieldTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "TextFieldTableViewCell")
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showCharacterSelector" {
            let controller = (segue.destinationViewController as UINavigationController).topViewController as CharacterTableViewController
            
            controller.setControllerWithContext(self.roll!.managedObjectContext!, characterObjectID: roll?.character?.objectID) {
                (character: PlayerCharacter?) -> Void in
                self.roll?.character = character
                self.tableView.reloadData()
            }
        }
        
    }
    
    
    
   
    // MARK: - UITableViewDataSource methods
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return 3
            case 1:
                return DieType.allDice.count
            case 2:
                return 1
            default:
                return 0
        }
    }
    
    
    // TODO: Make this prettier
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("TextFieldTableViewCell", forIndexPath: indexPath) as? UITableViewCell
                configureNameCell(cell as TextFieldTableViewCell)
            } else if indexPath.row == 1 {
                cell = tableView.dequeueReusableCellWithIdentifier("CharacterTableViewCell", forIndexPath: indexPath) as? UITableViewCell
                configureCharacterSelectionCell(cell!)
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("SwitchTableViewCell", forIndexPath: indexPath) as? UITableViewCell
                configureHighlightingCell(cell! as SwitchTableViewCell)
            }
            
        } else if indexPath.section == 1 {
            
            let dieType = DieType.allDice[indexPath.row]
            cell = tableView.dequeueReusableCellWithIdentifier("TextFieldTableViewCell", forIndexPath: indexPath) as? UITableViewCell
            configureDieCell(cell as TextFieldTableViewCell, forDieType: dieType)
            
        } else {
            
            cell = tableView.dequeueReusableCellWithIdentifier("TextFieldTableViewCell", forIndexPath: indexPath) as? UITableViewCell
            configureModifierCell(cell! as TextFieldTableViewCell)
            
        }
        
        return cell!
    }
    
    
    // TODO: This can be done better.
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section != 0 || indexPath.row == 0 {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as TextFieldTableViewCell
            cell.textField.becomeFirstResponder()
        }
    }
    
    
    func configureTextFieldCell(cell: TextFieldTableViewCell, withTitle title: String, andKey key: String) {
        cell.delegate = self
        cell.titleName = title
        cell.key = key
    }
    
    
    func configureNameCell(cell: TextFieldTableViewCell) {
        configureTextFieldCell(cell, withTitle: "Name", andKey: "name")
        
        cell.value = roll?.name ?? "Roll Name"
        cell.textField.keyboardType = .Default
        cell.textField.autocapitalizationType = .Words
    }
    
    
    func configureModifierCell(cell: TextFieldTableViewCell) {
        configureTextFieldCell(cell, withTitle: "Modifier", andKey: "modifier")

        cell.value = "\(roll!.modifier)"
        cell.textField.keyboardType = .NumberPad
    }
    
    
    func configureDieCell(cell: TextFieldTableViewCell, forDieType dieType: DieType) {
        configureTextFieldCell(cell, withTitle: dieType.toString().capitalizedString, andKey: dieType.toString())
        
        cell.value = "\(roll!.numberOfDie(dieType))"
        cell.textField.keyboardType = .NumberPad
    }
    
    
    func configureHighlightingCell(cell: SwitchTableViewCell) {
        cell.titleName = "Highlight Criticals"
        cell.toggle.key = "highlight"
        cell.toggle.on = roll?.highlight ?? false
        cell.toggle.addTarget(self, action: Selector("switchCellSwitchChangedState:"), forControlEvents: .ValueChanged)
    }
    
    func configureCharacterSelectionCell(cell: UITableViewCell) {
        cell.textLabel!.text = "Character"
        cell.detailTextLabel!.text = roll?.character?.name ?? "None"
    }
    
    
    
    
    
    
    // TODO: Dox
    func switchCellSwitchChangedState(toggle: UISwitch) {
        if let key = (toggle as KeyedSwitch).key {
            roll?.setValue(toggle.on, forKey: key)
        }
    }
    
    
    
    // MARK: - UITextFieldDelegate
    // TODO: Dox
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    // TODO: DRY? && Dox
    func textFieldDidEndEditing(textField: UITextField) {
        let keyedTextField = textField as KeyedTextField
        
        switch keyedTextField.key! {
            case "name":
                roll?.name = keyedTextField.text!
            case "modifier":
                roll?.modifier = keyedTextField.text.toInt() ?? 0
            default:
                roll?.setValue(keyedTextField.text.toInt() ?? 0, forKey: keyedTextField.key!)
        }
    }
    
    
    // MARK: - Actions
    
    /// Save the current Managed Object, and dismiss this View Controller.
    ///
    /// :param: sender The object sending the request to Save.
    @IBAction func save(sender: UIBarButtonItem) {
        
        // Ends editing within the View.
        self.view.endEditing(false)
        
        // If the roll is not nil, attempt to save.
        if let roll = self.roll {
            var error: NSError? = nil
            if !roll.managedObjectContext!.save(&error) {
                // TODO: Check for errors.
                abort()
            }
        }
        
        // Dismiss this view controller.
        dismiss()
    }
    
    
    /// Refresh object, and dismiss this View Controller.
    ///
    /// :param: sender The object sending the request to Cancel.
    @IBAction func cancel(sender: UIBarButtonItem) {
        
        // Refresh the object, without mergin changes (causes a fault).
        if let roll = self.roll {
            roll.managedObjectContext!.refreshObject(roll, mergeChanges: false)
        }
        
        // Dismiss this view controller.
        dismiss()
    }

    
    
    // MARK: EditRollViewController Methods
    
    /// Set the roll given the context and the object ID.
    ///
    /// By locating the roll using the context provided, we are free to edit the roll, and discard without saving, without affecting other views.
    ///
    /// :param: context The CoreData context, passed from previous Controller.
    /// :param: objectID The Object ID of the specific Roll we want to edit.
    func setRollFromContext(context: NSManagedObjectContext, andObjectID objectID: NSManagedObjectID, completion aCompletion: ((Roll?)->())?) {
        if let roll = context.objectWithID(objectID) as? Roll {
            self.roll = roll
        }
        completion = aCompletion
    }
    
    
    /// Dismiss this view controller.
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if completion != nil {
            completion!(self.roll)
        }
    }
    
}
