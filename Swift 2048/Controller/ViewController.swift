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

class ViewController: UIViewController, GameModeProtocol, GameModelProtocol, GridViewDelegate {
    var isModeUnlocked: Bool?
    var gameModel: GameModel!
    
    var timeModeDelegate: TimeModeProtocol!

    @IBOutlet var gridView: GridView!
    @IBOutlet var score: UILabel!
    @IBOutlet var highScore: UILabel!
    @IBOutlet var highScoreLabel: UILabel!
    @IBOutlet var gameOverView: UIView!
    @IBOutlet var gameOverScore: UILabel!
    @IBOutlet var modeLabel: UILabel!
    @IBOutlet var modeDetails: UILabel!
    
    var countdownTimer: NSTimer!
    var continueCountdownTime: Int!
//    var stepsLeft: Int!
    
    var gameOverScreenshot: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        gameModel = GameModel(delegate: self)
        timeModeDelegate = gameModel
        
        gameModel.currentMoveStep = gameModel.maxSteps
        
        updateHighScore()
        setupSwipeGestures()
    }
    
    func setupSwipeGestures() {
        // swipe gestures
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "swipeLeft")
        swipeLeft.direction = .Left
        gridView.addGestureRecognizer(swipeLeft)
        
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "swipeRight")
        swipeRight.direction = .Right
        gridView.addGestureRecognizer(swipeRight)
        
        var swipeUp = UISwipeGestureRecognizer(target: self, action: "swipeUp")
        swipeUp.direction = .Up
        gridView.addGestureRecognizer(swipeUp)
        
        var swipeDown = UISwipeGestureRecognizer(target: self, action: "swipeDown")
        swipeDown.direction = .Down
        gridView.addGestureRecognizer(swipeDown)
    }
    
    // MARK: Swipe actions
    
    func swipeLeft() {
        moveTile(CGPoint(x: -1, y: 0))
    }

    func swipeRight() {
        moveTile(CGPoint(x: 1, y: 0))
    }
    
    func swipeUp() {
        moveTile(CGPoint(x: 0, y: -1))
    }
    
    func swipeDown() {
        moveTile(CGPoint(x: 0, y: 1))
    }
    
    override func viewWillDisappear(animated: Bool) {
        if self.gameModel.gameMode == .TIME {
            continueCountdownTime = gameModel.currentCountdownTime
            timeModeDelegate.timeModePauseGame()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if self.gameModel.gameMode == .TIME && gameModel.currentCountdownTime != gameModel.maxCountdownTime {
            // Resume countdown if there's any
            timeModeDelegate.timeModeResumeGame(continueCountdownTime)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if gameModel.gameBoard == nil {
            gameModel.startGame()
            gridView.delegate = self
            
//            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "randomMove", userInfo: nil, repeats: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateScore() {
        score.text = String(gameModel.score)
        gameOverScore.text = String(gameModel.score)
    }
    
    func resetGame() {
        self.gridView.setNeedsDisplay()
        
        score.text = "0"
        gameModel.currentMoveStep = gameModel.maxSteps
        gameModel.currentCountdownTime = gameModel.maxCountdownTime
        updateHighScore()
        
        // Need some delay, since we redraw the grid view
        delay(0.2, closure: {
            self.gameModel.startGame()
        })
        
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
        timeModeDelegate.timeModePauseGame()
        continueCountdownTime = gameModel.currentCountdownTime
        
        let alertView = SIAlertView(title: "New Game", andMessage: "Current score will be erased! Do you want to restart the game?")
        alertView.transitionStyle = SIAlertViewTransitionStyle.Fade
        
        alertView.addButtonWithTitle("Cancel", type: .Cancel, handler: {
            (SIAlertViewHandler) in
            
            if self.gameModel.gameMode == .TIME {
                // Resume countdown
                self.timeModeDelegate.timeModeResumeGame(self.continueCountdownTime)
            }
            
        })
        
        alertView.addButtonWithTitle("New Game", type: .Destructive, handler: {
            (SIAlertViewHandler) in
                self.resetGame()
                if self.gameModel.gameMode == .TIME {
                    self.timeModeDelegate.timeModeStartGame()
                }
        })
        
        alertView.show()
    }
    
    @IBAction func shareScore(sender: AnyObject) {
        let shareText = "I'm playing 2048! I've got \(score.text!)"
        
        let shareSheet = UIActivityViewController(activityItems: [shareText, gameOverScreenshot], applicationActivities: nil)
        self.presentViewController(shareSheet, animated: true, completion: nil)
    }
    
    @IBAction func resetGame(sender: AnyObject) {
        changeGameMode(gameModel.gameMode)
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
                timeModeDelegate.timeModeStartGame()
            case .STEP:
                modeLabel.text = "Step Mode"
                highScoreLabel.text = "Step"
        }
        
        updateHighScore()
        gameModel.gameMode = mode
        resetGame()
    }
    
    func takeScreenshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(UIScreen.mainScreen().bounds.size, false, 0);
        self.view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
        var image:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image
    }
    
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    // MARK: GameModelProtocol
    
    func updateHighScore() {
        
        switch gameModel.gameMode {
        case .CLASSIC:
            var highestScore =  NSUserDefaults.standardUserDefaults().objectForKey("highScore") as? NSInteger
            
            if highestScore == nil {
                highestScore = 0
                NSUserDefaults.standardUserDefaults().setObject(0, forKey: "highScore")
            }
            
            highScore.text = String(highestScore!)
        case .TIME:
            if gameModel.currentCountdownTime >= 0 {
                highScore.text = String(gameModel.currentCountdownTime)
            }
        case .STEP:
            highScore.text = String(gameModel.currentMoveStep)
        }
    }
    
    func stepMoved() {
        updateHighScore()
    }
    
    func gameOver(){
        gameOverScreenshot = takeScreenshot()
        
        self.gameOverView.hidden = false
        UIView.animateWithDuration(0.5, animations: {
            self.gameOverView.alpha = 1
        })
    }
    
    func moveTile(direction: CGPoint) {
        gameModel.move(direction)
    }
    
    func addTileAtPosition(tile: TileView, column: Int, row: Int) {
        gridView.animateAddTileAtColumn(tile, column: column, row: row)
    }
    
    func moveTile(tile: TileView, oldX: NSInteger, oldY: NSInteger, newX: NSInteger, newY: NSInteger) {
        gridView.animateMoveTile(tile, oldX: oldX, oldY: oldY, newX: newX, newY: newY)
    }
    
    func mergeTileAtIndex(oldTile: TileView, newTile: TileView, x: NSInteger, y: NSInteger, otherTileX: NSInteger, otherTileY: NSInteger) {
        // If merge, means we can update the score
        updateScore()
        gridView.animateMergeTileAtIndex(oldTile, newTile: newTile, x: x, y: y, otherTileX: otherTileX, otherTileY: otherTileY)
    }
    
    // MARK: GridViewProtocol
    
    func restartGameAfterRedraw(value: Bool) {
        if value {
            gameModel.startGame()
        }
    }
    
    func randomMove(){
        let possibleMove = [CGPoint(x: -1, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 0, y: -1), CGPoint(x: 0, y: 1)] as [CGPoint]
        
        for i in 0...(possibleMove.count - 1) {
            if gameModel.move(possibleMove[i]) {
                break
            }
        }
    }
    
}

