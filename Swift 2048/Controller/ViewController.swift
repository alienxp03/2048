//
//  ViewController.swift
//  Swift 2048
//
//  Created by tokwan on 10/12/2014.
//  Copyright (c) 2014 alienxp03. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var gridBoard: GridView!
    @IBOutlet var score: UILabel!
    @IBOutlet var highScore: UILabel!
    @IBOutlet var gameOverView: UIView!
    @IBOutlet var gameOverScore: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateScore", name:"UpdateScore", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateHighScore", name:"UpdateHighScore", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gameOver", name:"GameOver", object: nil)
        
        updateHighScore()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateScore() {
        score.text = String(gridBoard.score)
    }
    
    func updateHighScore() {
        var highestScore =  NSUserDefaults.standardUserDefaults().objectForKey("highScore") as NSInteger
        highScore.text = String(highestScore)
    }
    
    func gameOver(){
        self.gameOverView.hidden = false
        UIView.animateWithDuration(0.5, animations: {
            self.gameOverView.alpha = 1
        })
    }
    
    @IBAction func shareScore(sender: AnyObject) {
        
    }
    
    @IBAction func resetGame(sender: AnyObject) {
        score.text = "0"
        updateHighScore()
        self.gridBoard.setNeedsDisplay()
        
        UIView.animateWithDuration(0.5, animations: {
            self.gameOverView.alpha = 0
            }, completion: {
                (value: Bool) in
                self.gameOverView.hidden = true
        })
    }
}

