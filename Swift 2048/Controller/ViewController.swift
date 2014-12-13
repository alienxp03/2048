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

class ViewController: UIViewController, GameModeProtocol, GameModelProtocol {
    var isModeUnlocked: Bool?
    var gameModel: GameModel!
    
    var timeModeDelegate: FunAndTimeModeProtocol!

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
    
    override func viewWillDisappear(animated: Bool) {
        if self.gameModel.gameMode == .FUN {
            timeModeDelegate.funAndTimeModePauseGame()
        } else if self.gameModel.gameMode == .TIME {
            // Pause the timer for game mode, if user is going to other view
            continueCountdownTime = gameModel.currentCountdownTime
            timeModeDelegate.funAndTimeModePauseGame()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if gameModel.gameMode == GameModeType.FUN && gameModel.gameState == GameState.PAUSE {
            timeModeDelegate.funAndTimeModeResumeGame(0)
        } else if gameModel.gameMode == .TIME && gameModel.currentCountdownTime != gameModel.maxCountdownTime {
            // Resume the timer for game mode, if user is coming back from another view
            timeModeDelegate.funAndTimeModeResumeGame(continueCountdownTime)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if gameModel.gameBoard == nil {
            gameModel.startGame()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: Swipe actions
    
    /*
        Setup swipe gestures to the GridView, not the current view controller's view
    */
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
    
    func swipeLeft() {
        moveTile(MoveLeft)
    }

    func swipeRight() {
        moveTile(MoveRight)
    }
    
    func swipeUp() {
        moveTile(MoveUp)
    }
    
    func swipeDown() {
        moveTile(MoveDown)
    }
    
    func updateScore() {
        score.text = String(gameModel.score)
        gameOverScore.text = String(gameModel.score)
    }
    
    // MARK: IBActions
    
    @IBAction func showMenu(sender: AnyObject) {
        let menuViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MenuViewController") as MenuViewController
        menuViewController.delegate = self
        menuViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.presentViewController(menuViewController, animated: true, completion: nil)
    }
    
    @IBAction func restartGame(sender: AnyObject) {
        timeModeDelegate.funAndTimeModePauseGame()
        continueCountdownTime = gameModel.currentCountdownTime
        
        let alertView = SIAlertView(title: "New Game", andMessage: "Current score will be erased! Do you want to restart the game?")
        alertView.transitionStyle = SIAlertViewTransitionStyle.Fade
        
        alertView.addButtonWithTitle("Cancel", type: .Cancel, handler: {
            (SIAlertViewHandler) in
            
            if self.gameModel.gameMode == .FUN {
                self.timeModeDelegate.funAndTimeModeResumeGame(0)
            } else if self.gameModel.gameMode == .TIME {
                // Resume countdown
                self.timeModeDelegate.funAndTimeModeResumeGame(self.continueCountdownTime)
            }
            
        })
        
        alertView.addButtonWithTitle("New Game", type: .Destructive, handler: {
            (SIAlertViewHandler) in
                self.resetGame()
                if self.gameModel.gameMode == .FUN {
                    self.timeModeDelegate.funAndTimeModePauseGame()
                } else if self.gameModel.gameMode == .TIME {
                    self.timeModeDelegate.funAndTimeModeStartGame()
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
    
    // MARK:
    
    /*
        Delay the action in the block for few second/s
    */
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    /*
        Try to move a tile at a certain direction
    */
    func moveTile(direction: CGPoint) {
        gameModel.move(direction)
    }
    
    /*
        Change the game mode using a delegate to the game model
    */
    func changeGameMode(mode: GameModeType) {
        countdownTimer?.invalidate()
        
        switch mode {
        case .CLASSIC:
            modeLabel.text = "Classic Mode"
            highScoreLabel.text = "Best"
        case .TIME:
            modeLabel.text = "Time Mode"
            highScoreLabel.text = "Time"
            timeModeDelegate.funAndTimeModeStartGame()
        case .STEP:
            modeLabel.text = "Step Mode"
            highScoreLabel.text = "Step"
        case .FUN:
            modeLabel.text = "Fun Mode"
            highScoreLabel.text = "Best"
        }
        
        updateHighScore()
        gameModel.gameMode = mode
        resetGame()
    }
    
    /*
        Take a screeenshot of the current screen. 
    
        @returns A UIImage object
    */
    func takeScreenshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(UIScreen.mainScreen().bounds.size, false, 0);
        self.view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
        var image:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image
    }
    
    /*
        Reset the game state using the game model delegate
    */
    func resetGame() {
        if let recognizers = gridView.gestureRecognizers as? [UIGestureRecognizer] {
            for recognizer in recognizers {
                gridView.removeGestureRecognizer(recognizer)
            }
        }
        
        // User can't move in Fun mode
        if gameModel.gameMode !=  .FUN {
            setupSwipeGestures()
        }
        
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
    
    // MARK: GameModelProtocol
    
    func updateHighScore() {
        
        switch gameModel.gameMode {
        case .CLASSIC, .FUN:
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
    
    /*
        A step move means we're in Step Mode. We update the highscore because the steps label is the same as the highscore
    */
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

