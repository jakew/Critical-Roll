//
//  EditCharacterViewController.swift
//  Critical Roll
//
//  Created by Jake Winters on 2014-12-25.
//  Copyright (c) 2014 Jake Winters. All rights reserved.
//

import UIKit
import CoreData

class EditCharacterViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    var character: PlayerCharacter?
    
    override func viewDidLoad() {
        let nib = UINib(nibName: "TextFieldTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "TextFieldTableViewCell")
    }
    
    //TODO: This should be happening in it's own contaxt.
    override func viewWillDisappear(animated: Bool) {
        self.view.endEditing(false)
        
        if character != nil {
            var error: NSError? = nil
            if !character!.managedObjectContext!.save(&error) {
                // TODO: Check for errors.
                
                NSLog("Error saving information: \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("TextFieldTableViewCell", forIndexPath: indexPath) as UITableViewCell
        
        self.configureCellForCharacterName(cell as TextFieldTableViewCell, forIndexPath: indexPath)
        
        return cell
    }
    
    func createTextFieldTableViewCellForTableView(tableView: UITableView, forIndexPath indexPath: NSIndexPath, forKey key: String, title: String) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("TextFieldTableViewCell", forIndexPath: indexPath) as TextFieldTableViewCell
        configureCellForCharacterName(cell, forIndexPath: indexPath)
        return cell as TextFieldTableViewCell
    }
    
    func configureCellForCharacterName(cell: TextFieldTableViewCell, forIndexPath: NSIndexPath){
        cell.delegate = self
        cell.titleName = "Character Name"
        cell.key = "name"
        
        if let value: AnyObject = character?.valueForKey("name")! {
            cell.value = "\(value)"
        }
    }
    
    
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // TODO: DRY?
    func textFieldDidEndEditing(textField: UITextField) {
        let keyedTextFeild = textField as KeyedTextField
        character?.setValue(keyedTextFeild.text!, forKey: keyedTextFeild.key!)
    }
}
