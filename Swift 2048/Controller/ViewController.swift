//
//  ViewController.swift
//  Swift 2048
//
//  Created by tokwan on 10/12/2014.
//  Copyright (c) 2014 alienxp03. All rights reserved.
//

import UIKit
import StoreKit

protocol GameModeProtocol {
    func changeGameMode(mode: GameModeType)
}

class ViewController: UIViewController, GameModeProtocol {
    var isModeUnlocked: Bool?
    var model: GameModel!

    @IBOutlet var gridBoard: GridView!
    @IBOutlet var score: UILabel!
    @IBOutlet var highScore: UILabel!
    @IBOutlet var highScoreLabel: UILabel!
    @IBOutlet var gameOverView: UIView!
    @IBOutlet var gameOverScore: UILabel!
    @IBOutlet var modeLabel: UILabel!
    @IBOutlet var modeDetails: UILabel!
    
    var countdownTimer: NSTimer!
    var countdownTime: Int!
    var continueCountdownTime: Int!
    var stepsLeft: Int!
    
    var gameModeDelegate: GameModeProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        model = GameModel.sharedInstance
        countdownTime = model.maxCountdownTime
        stepsLeft = model.maxSteps
        
        println("Set \(countdownTime)")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateScore", name:"UpdateScore", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateHighScore", name:"UpdateHighScore", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gameOver", name:"GameOver", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateHighScore", name:skStepMoved, object: nil)
        
        updateHighScore()
    }
    
    override func viewWillDisappear(animated: Bool) {
        if self.model.gameMode == .TIME {
            continueCountdownTime = countdownTime
            countdownTimer?.invalidate()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if self.model.gameMode == .TIME && countdownTime != model.maxCountdownTime {
            // Resume countdown if there's any
            self.countdownTime = continueCountdownTime
            self.countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "countdown", userInfo: nil, repeats: true)
        }
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
        
        switch model.gameMode {
            case .CLASSIC:
                var highestScore =  NSUserDefaults.standardUserDefaults().objectForKey("highScore") as? NSInteger
                
                if highestScore == nil {
                    highestScore = 0
                    NSUserDefaults.standardUserDefaults().setObject(0, forKey: "highScore")
                }
                
                highScore.text = String(highestScore!)
            case .TIME:
                if countdownTime >= 0 {
                    highScore.text = String(countdownTime!)
                }
            case .STEP:
                highScore.text = String(stepsLeft!--)
            
                if highScore.text == "0" {
                    gameOver()
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
        stepsLeft = model.maxSteps
        countdownTime = model.maxCountdownTime
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
        continueCountdownTime = countdownTime
        countdownTimer?.invalidate()
        
        let alertView = SIAlertView(title: "New Game", andMessage: "Current score will be erased! Do you want to restart the game?")
        alertView.transitionStyle = SIAlertViewTransitionStyle.Fade
        
        alertView.addButtonWithTitle("Cancel", type: .Cancel, handler: {
            (SIAlertViewHandler) in
            
            if self.model.gameMode == .TIME {
                // Resume countdown if there's any
                self.countdownTime = self.continueCountdownTime
                self.countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "countdown", userInfo: nil, repeats: true)
            }
            
        })
        
        alertView.addButtonWithTitle("New Game", type: .Destructive, handler: {
            (SIAlertViewHandler) in
                self.resetGame()
                if self.model.gameMode == .TIME {
                    self.countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "countdown", userInfo: nil, repeats: true)
                }
        })
        
        alertView.show()
    }
    
    @IBAction func shareScore(sender: AnyObject) {
        
    }
    
    @IBAction func resetGame(sender: AnyObject) {
        changeGameMode(model.gameMode)
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
                countdownTime = model.maxCountdownTime
                countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "countdown", userInfo: nil, repeats: true)
            case .STEP:
                modeLabel.text = "Step Mode"
                highScoreLabel.text = "Step"
        }
        
        updateHighScore()
        model.gameMode = mode
        resetGame()
    }
    
    func countdown() {
        var time = countdownTime!--
        updateHighScore()
        
        if time < 1 {
            countdownTimer?.invalidate()
            gameOver()
        }
    }
}

