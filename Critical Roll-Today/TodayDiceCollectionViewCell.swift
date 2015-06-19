//
//  TodayDiceCollectionViewCell.swift
//  Critical Roll
//
//  Created by Jake Winters on 2015-01-09.
//  Copyright (c) 2015 Jake Winters. All rights reserved.
//

import UIKit

@IBDesignable
class TodayDiceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var rollLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet weak var innerVisualEffectView: UIVisualEffectView?

    
    
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            NSLog("Corner Radious was set to \(cornerRadius)")
            self.layer.cornerRadius = cornerRadius
            
            layer.masksToBounds = true
        }
    }
    
    
    var result: Int? {
        didSet {
            resultLabel.text = "\(self.result ?? 0)"
        }
    }
}
