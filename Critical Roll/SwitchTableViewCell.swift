//
//  SwitchTableViewCell.swift
//  Critical Roll
//
//  Created by Jake Winters on 2014-12-22.
//  Copyright (c) 2014 Jake Winters. All rights reserved.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var toggle: KeyedSwitch!
    @IBOutlet weak var title: UILabel!
    
    var titleName: String? {
        didSet {
            title.text = titleName
        }
    }
    
}
