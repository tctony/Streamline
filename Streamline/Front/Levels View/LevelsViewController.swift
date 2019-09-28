//
//  ViewController.swift
//  Streamline
//
//  Created by Xuezheng Wang on 9/17/19.
//  Copyright © 2019 Xuezheng Wang. All rights reserved.
//

import UIKit

let ID = "LevelCell"

class LevelsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var gameDelegate: GameLogicDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Collection View related
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameDelegate.getNumLevels()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ID, for: indexPath) as! LevelViewCell
        
        // Set the level number for each cell
        cell.levelLabel.text = String(indexPath.item + 1)
        cell.levelNumber = indexPath.item
        
        return cell
    }
    

    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is GameViewController
        {
            let vc = segue.destination as? GameViewController
            vc!.currentLevel = (sender as! LevelViewCell).levelNumber
            vc!.gameDelegate = gameDelegate
        }
        
    }
    
    @IBAction func handlesBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {})
    }
}
