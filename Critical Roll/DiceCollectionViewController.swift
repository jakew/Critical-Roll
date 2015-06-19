//
//  DiceCollectionViewController.swift
//  Critical Roll
//
//  Created by Jake Winters on 2015-01-05.
//  Copyright (c) 2015 Jake Winters. All rights reserved.
//

import UIKit

class DiceCollectionViewController: UICollectionViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var listOfDice: [Die] = []
    
    override func viewDidLoad() {
        for dieType in DieType.allDice {
            listOfDice += [Die(ofType: dieType)]
        }
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listOfDice.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("DieCell", forIndexPath: indexPath) as UICollectionViewCell
        configureCollectionView(cell as DiceCollectionVieWCell, atIndexPath: indexPath)
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.listOfDice[indexPath.row].roll()
        configureCollectionView(collectionView.cellForItemAtIndexPath(indexPath)! as DiceCollectionVieWCell, atIndexPath: indexPath)
    }
    
    func configureCollectionView(cell: DiceCollectionVieWCell, atIndexPath indexPath: NSIndexPath) {
        let die = listOfDice[indexPath.row]
        if die.criticalHit() {
            cell.rollValue.textColor = UIColor.redColor()
        } else if die.criticalMiss() {
            cell.rollValue.textColor = UIColor.blueColor()
        } else {
            cell.rollValue.textColor = UIColor.blackColor()
        }
        
        cell.value = die.value
        cell.dieType = listOfDice[indexPath.row].type
    }

}