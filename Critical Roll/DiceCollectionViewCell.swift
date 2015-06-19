//
//  DiceCollectionViewCell.swift
//  Critical Roll
//
//  Created by Jake Winters on 2015-01-05.
//  Copyright (c) 2015 Jake Winters. All rights reserved.
//

import UIKit

class DiceCollectionVieWCell: UICollectionViewCell {
    
    @IBOutlet weak var dieIcon: UIImageView!
    @IBOutlet weak var rollLabel: UILabel!
    @IBOutlet weak var rollValue: UILabel!
    

    @IBInspectable var borderColor: UIColor = UIColor.lightGrayColor()
    
    var value: Int = 0 {
        didSet {
            self.rollValue.text = "\(value)"
        }
    }
    
    var dieType: DieType = DieType.D4 {
        didSet {
            self.rollLabel.text = "Roll \(self.dieType.toString())"
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configureViews()
    }
    
    func configureViews() {
        self.contentView.layer.borderColor = self.borderColor.CGColor
    }
}