//
//  TodayViewController.swift
//  Critical Roll-Today
//
//  Created by Jake Winters on 2015-01-07.
//  Copyright (c) 2015 Jake Winters. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var listOfDice: [Die] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout!
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        for dieType in DieType.allDice {
            listOfDice += [Die(ofType: dieType)]
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
        self.collectionViewHeight.constant = self.collectionViewLayout.collectionViewContentSize().height
    }
    
    // MARK: - UICollectionViewDataSource methods
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listOfDice.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("TodayDieCollectionViewCell", forIndexPath: indexPath) as UICollectionViewCell
        
        self.configureCell(cell, forIndexPath: indexPath)

        return cell
    }
    
    func configureCell(aCell: UICollectionViewCell, forIndexPath indexPath: NSIndexPath) {
        
        NSLog("configuring a cell at \(indexPath.section) and \(indexPath.row)")
        if let cell = aCell as? TodayDiceCollectionViewCell {
            
            cell.rollLabel.text = "\(listOfDice[indexPath.row].type.toString().uppercaseString)"
            cell.result = listOfDice[indexPath.row].value
            
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        listOfDice[indexPath.row].roll()
        configureCell(self.collectionView.cellForItemAtIndexPath(indexPath)!, forIndexPath: indexPath)
    }
    
    
}
