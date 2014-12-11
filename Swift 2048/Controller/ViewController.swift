//
//  ViewController.swift
//  Swift 2048
//
//  Created by tokwan on 10/12/2014.
//  Copyright (c) 2014 alienxp03. All rights reserved.
//

import UIKit

protocol GameModeProtocol {
    func changeGameMode(mode: GameModeType)
}

class ViewController: UIViewController, GameModeProtocol {
    
    var model: GameModel!

    @IBOutlet var gridBoard: GridView!
    @IBOutlet var score: UILabel!
    @IBOutlet var highScore: UILabel!
    @IBOutlet var highScoreLabel: UILabel!
    @IBOutlet var gameOverView: UIView!
    @IBOutlet var gameOverScore: UILabel!
    @IBOutlet var modeLabel: UILabel!
    @IBOutlet var modeDetails: UILabel!
    
    var countdownTimer:NSTimer?
    var maxCountdownTime:Int?
    
    var gameModeDelegate: GameModeProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        model = GameModel.sharedInstance
        maxCountdownTime = model.maxCountdownTime
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateScore", name:"UpdateScore", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateHighScore", name:"UpdateHighScore", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gameOver", name:"GameOver", object: nil)
        
        updateHighScore()
    }
    
    override func viewWillAppear(animated: Bool) {
        // cancel the timer if there is any
//        countdownTimer?.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateScore() {
        score.text = String(model.score)
        gameOverScore.text = String(model.score)
    }
    
    func updateHighScore() {
        
        switch model.mode {
            case .CLASSIC:
                var highestScore =  NSUserDefaults.standardUserDefaults().objectForKey("highScore") as NSInteger
                highScore.text = String(highestScore)
            case .TIME:
                if maxCountdownTime >= 0 {
                    highScore.text = String(maxCountdownTime!)
                }
        }
    }
    
    func gameOver(){
        self.gameOverView.hidden = false
        UIView.animateWithDuration(0.5, animations: {
            self.gameOverView.alpha = 1
        })
    }
    
    func resetGame() {
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
    
    // MARK: IBActions
    
    @IBAction func showMenu(sender: AnyObject) {
        let menuViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MenuViewController") as MenuViewController
        menuViewController.delegate = self
        menuViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.presentViewController(menuViewController, animated: true, completion: nil)
    }
    
    @IBAction func restartGame(sender: AnyObject) {
        let alertView = SIAlertView(title: "New Game", andMessage: "Current score will be erased! Do you want to restart the game?")
        alertView.transitionStyle = SIAlertViewTransitionStyle.Fade
        
        alertView.addButtonWithTitle("Cancel", type: .Cancel, handler: nil)
        
        alertView.addButtonWithTitle("New Game", type: .Destructive, handler: {
            (SIAlertViewHandler) in
            self.resetGame()
        })
        
        alertView.show()
    }
    
    @IBAction func shareScore(sender: AnyObject) {
        
    }
    
    @IBAction func resetGame(sender: AnyObject) {
        changeGameMode(model.mode)
    }
    
    func changeGameMode(mode: GameModeType) {
        countdownTimer?.invalidate()
        
        switch mode {
            case .CLASSIC:
                modeLabel.text = "Classic Mode"
                highScoreLabel.text = "Best"
            case .TIME:
                modeLabel.text = "Time Mode"
                highScoreLabel.text = "Time"
                maxCountdownTime = model.maxCountdownTime
                countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "countdown", userInfo: nil, repeats: true)
        }
        
        updateHighScore()
        model.mode = mode
        resetGame()
    }
    
    func countdown() {
        var time = maxCountdownTime!--
        updateHighScore()
        
        if time < 1 {
            countdownTimer?.invalidate()
            gameOver()
        }
    }
}

