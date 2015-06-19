//
//  TextFieldTableViewCell.swift
//  Critical Roll
//
//  Created by Jake Winters on 2014-11-15.
//  Copyright (c) 2014 Jake Winters. All rights reserved.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var textField: KeyedTextField!
    @IBOutlet weak var title: UILabel!
    
    var key: String? {
        didSet {
            textField.key = key
        }
    }
    
    var value: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
        }
    }
    
    var titleName: String? {
        didSet {
            title.text = titleName
            textField.placeholder = titleName
        }
    }
    
    var delegate: UITextFieldDelegate? {
        get {
            return self.textField.delegate
        }
        set {
            self.textField.delegate = newValue
        }
    }
    
    func createTextFieldForTableViewCell(tableView: UITableView, forIndexPath indexPath: NSIndexPath) -> TextFieldTableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("TextFieldTableViewCell", forIndexPath: indexPath) as TextFieldTableViewCell
        
        
        
        return cell
    }
}
