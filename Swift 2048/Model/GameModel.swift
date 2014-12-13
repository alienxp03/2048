//
//  GameModel.swift
//  Swift 2048
//
//  Created by tokwan on 11/12/2014.
//  Copyright (c) 2014 alienxp03. All rights reserved.
//

import UIKit

let gridSize                = 4
let kStepModeNotification   = "kStepModeNotification"
let skStepMoved             = "StepMoved"

class GameModel: TimeModeProtocol {
    
    let maxCountdownTime        = 150
    let maxSteps                = 3
    let startTiles              = 2
    
    var score                   = 0
    var gameMode: GameModeType  = .CLASSIC
    var currentMoveStep         = 0
    var gameBoard: Array<Array<Any>>!
    var gameState: GameState!
    
    // to communicate with the parent controller
    let delegate: GameModelProtocol!
    
    // For timer mode
    var countdownTimer: NSTimer!
    var currentCountdownTime: Int!
    
    init(delegate: GameModelProtocol) {
        self.delegate = delegate
    }
    
    func startGame() {
        gameBoard = Array<Array<Any>>()
        
        for var i = 0; i < gridSize; i++ {
            var columnArray = Array<Any>()
            for var j = 0; j < gridSize; j++ {
                columnArray.append(NSNull())
            }
            gameBoard.append(columnArray)
        }
        
        spawnStartTiles()
        
        gameState = .RUNNING
    }
    
    /*
    Add/create a tile at given position
    */
    func addTileAtColumn(column: NSInteger, row: NSInteger) {
        var tile = TileView()
        gameBoard[column][row] = tile
        delegate.addTileAtPosition(tile, column: column, row: row)
    }
    
    /*
    Spawn a random tile at random position
    */
    func spawnRandomTile() {
        var spawned = false
        while !spawned {
            var randomColumn = Int(arc4random_uniform(UInt32(gridSize)))
            var randomRow = Int(arc4random_uniform(UInt32(gridSize)))
            var positionFree = (gameBoard[randomColumn][randomRow] as? NSNull == NSNull())
            if positionFree {
                addTileAtColumn(randomColumn, row: randomRow)
                spawned = true
            }
        }
    }
    
    /*
    Start to spawn tiles based on how many initial startTiles that we have declared
    */
    func spawnStartTiles() {
        for var i = 0; i < startTiles; i++ {
            spawnRandomTile()
        }
    }
    
    /*
    CHeck if the given position is a valid index for our game board
    */
    func indexValid(x: NSInteger, y: NSInteger) -> Bool {
        var indexValid = true
        indexValid &= x >= 0
        indexValid &= y >= 0
        
        if indexValid {
            indexValid &= x < gameBoard.count
            if indexValid {
                indexValid &= y < gameBoard[x].count
            }
        }
        return indexValid
    }
    
    /*
    Check if a given position is valid and unoccupied
    */
    func indexValidAndUnoccupied(x: NSInteger, y: NSInteger) -> Bool {
        var indexValid = self.indexValid(x, y: y)
        if !indexValid {
            return false
        }
        var unoccupied = (gameBoard[x][y] as? NSNull == NSNull())
        return unoccupied
    }
    
    /*
        Move tile based on the direction
    */
    
    func move(direction: CGPoint) -> Bool {
        var movedTilesThisRound = false
        var currentX:NSInteger = 0
        var currentY:NSInteger = 0
        
        while(self.indexValid(currentX, y: currentY)) {
            var newX:NSInteger = currentX + NSInteger(direction.x)
            var newY:NSInteger = currentY + NSInteger(direction.y)
            if self.indexValid(newX, y: newY) {
                currentX = newX
                currentY = newY
            } else {
                break
            }
        }
        
        // store initial row value to reset after completing each column
        var initialY = currentY
        // define changing of x and y value ( moving left, right, up or down? )
        var xChange = Int(-direction.x)
        var yChange = Int(-direction.y)
        
        if xChange == 0 {
            xChange = 1
        }
        if yChange == 0 {
            yChange = 1
        }
        
        // visit column for column
        while self.indexValid(currentX, y: currentY) {
            while self.indexValid(currentX, y: currentY) {
                // get tile at current index
                var tile = gameBoard[currentX][currentY] as? TileView
                if tile == nil {
                    // if there is no tile at this index -> skip
                    currentY += NSInteger(yChange)
                    continue
                }
                
                // store index in temp variable to change them and store new location of this tile
                var newX:NSInteger = currentX
                var newY:NSInteger = currentY
                // find the farthest position by iterating in direction of the vector until we reach border of  grid of occupied cell
                while self.indexValidAndUnoccupied(newX + NSInteger(direction.x), y: newY + NSInteger(direction.y)) {
                    newX += NSInteger(direction.x)
                    newY += NSInteger(direction.y)
                }
                
                var performMove = false
                
                if indexValid(newX + NSInteger(direction.x), y: newY + NSInteger(direction.y)) {
                    // get the other tile
                    var otherTileX = newX + NSInteger(direction.x)
                    var otherTileY = newY + NSInteger(direction.y)
                    var otherTile = gameBoard[otherTileX][otherTileY] as TileView
                    // compare value of other tile and also check if the other tile has been merged this round
                    if tile?.value == otherTile.value && !otherTile.mergedThisRound {
                        // merge tiles
                        // TODO:
                        mergeTileAtIndex(currentX, y: currentY, otherTileX: otherTileX, otherTileY: otherTileY)
                        movedTilesThisRound = true
                    } else {
                        performMove = true
                    }
                } else {
                    // we cannot merge so we want to perform a move
                    performMove = true
                }
                
                if performMove {
                    // move tile to furthest position
                    if newX != currentX || newY != currentY {
                        // TODO:
                        moveTile(tile!, oldX: currentX, oldY: currentY, newX: newX, newY: newY)
                        movedTilesThisRound = true
                    }
                }
                
                // move further in this column
                currentY += yChange
            }
            
            // move to the next column, start at the initial row
            currentX += xChange
            currentY = initialY
        }
        
        if movedTilesThisRound {
            currentMoveStep--
            delegate.stepMoved()
            nextRound()
            return true
        }
        
        return false
    }
    
    /*
    Merge two tiles together. After merge, we remove one of the tile from the view
    */
    func mergeTileAtIndex(x: NSInteger, y: NSInteger, otherTileX: NSInteger, otherTileY: NSInteger) {
        // update game data
        var mergedTile = gameBoard[x][y] as TileView
        var otherTile = gameBoard[otherTileX][otherTileY] as TileView
        score += mergedTile.value + otherTile.value
        otherTile.value *= 2
        otherTile.mergedThisRound = true
        gameBoard[x][y] = NSNull()
        
        delegate.mergeTileAtIndex(mergedTile, newTile: otherTile, x: x, y: y, otherTileX: otherTileX, otherTileY: otherTileY)
    }
    
    /*
    Move a tile to a new position
    */
    func moveTile(tile: TileView, oldX: NSInteger, oldY: NSInteger, newX: NSInteger, newY: NSInteger) {
        gameBoard[newX][newY] = gameBoard[oldX][oldY]
        gameBoard[oldX][oldY] = NSNull()
        delegate.moveTile(tile, oldX: oldX, oldY: oldY, newX: newX, newY: newY)
    }
    
    /*
    Start the next round, since the user already lost the game
    */
    func nextRound() {
        spawnRandomTile()
        
        for var i = 0; i < gridSize; i++ {
            for var j = 0; j < gridSize; j++ {
                let tile = gameBoard[i][j] as? TileView
                if tile != nil {
                    tile?.mergedThisRound = false
                }
            }
        }
        
        var possibleToMove = movePossible()
        if !possibleToMove {
            endGame()
        }
    }
    
    /*
    Check if user still have an possible. If there isn't one, it means game over
    */
    func movePossible() -> Bool {
        
        // Only for step mode
        if gameMode == .STEP {
            if currentMoveStep <= 0 {
                gameState = .GAMEOVER
                return false
            }
        }
        
        for var i = 0; i < gridSize; i++ {
            for var j = 0; j < gridSize; j++ {
                var tile = gameBoard[i][j] as? TileView
                if tile == nil {
                    return true
                } else {
                    var topNeighbour = tileForIndex(i, y: j + 1) as? TileView
                    var bottomNeighbour = tileForIndex(i, y: j - 1) as? TileView
                    var leftNeighbour = tileForIndex(i - 1, y: j) as? TileView
                    var rightNeighbour = tileForIndex(i + 1, y: j) as? TileView
                    var neightbours = [topNeighbour, bottomNeighbour, leftNeighbour, rightNeighbour]
                    for neightbourTile in neightbours {
                        if neightbourTile != nil {
                            var neighbour = neightbourTile!
                            if neighbour.value == tile?.value {
                                return true
                            }
                        }
                    }
                }
            }
        }
        
        gameState = .GAMEOVER
        return false
    }
    
    /*
        Get gameBoard size, all tiles that are not null
    */
    func gameBoardSize() -> Int {
        var size = 0
        
        for var i = 0; i < gridSize; i++ {
            for var j = 0; j < gridSize; j++ {
                if let tile = gameBoard[i][j] as? TileView {
                    size++
                }
            }
        }
        
        return size
    }
    
    /*
    Get a tile for given index
    */
    func tileForIndex(x: NSInteger, y: NSInteger) -> Any {
        if !indexValid(x, y: y) {
            return NSNull()
        } else {
            return gameBoard[x][y]
        }
    }
    
    /*
    End the game, update the scores
    */
    func endGame() {
        var highScore = NSUserDefaults.standardUserDefaults().objectForKey("highScore") as? NSInteger
        
        if score > highScore || highScore == nil {
            highScore = score
            NSUserDefaults.standardUserDefaults().setObject(highScore, forKey: "highScore")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            delegate.updateHighScore()
        }
        
        gameState = .GAMEOVER
        delegate.gameOver()
    }
    
    // MARK: Just for fun
    
    /*
        Move randomly
        // TODO: Maybe can try to implement AI
    */
    func randomMove(){
        let possibleMove = [CGPoint(x: -1, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 0, y: -1), CGPoint(x: 0, y: 1)] as [CGPoint]
        
        for i in 0...(possibleMove.count-1) {
            if move(possibleMove[i]) {
                break
            }
        }
    }
    
    
    /*
        Print the game board to the console
    */
    func displayGameBoardToConsole() {
        for var i = 0; i < gridSize; i++ {
            for var j = 0; j < gridSize; j++ {
                if let tile = gameBoard[i][j] as? TileView {
                    print(" \(tile.value) ")
                } else {
                    print(" 0 ")
                }
            }
            println()
        }
//        println("Board \(gameBoardSize())")
    }
    
    
    // MARK: TimeModeProtocol
    
    func timeModeStartGame() {
        currentCountdownTime = maxCountdownTime
        countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "countdown", userInfo: nil, repeats: true)
    }
    
    func timeModePauseGame() {
        countdownTimer.invalidate()
    }
    
    func timeModeResumeGame(time: Int) {
        currentCountdownTime = time
        countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "countdown", userInfo: nil, repeats: true)
    }
    
    func timeModeGameOver() {
        
    }
    
    // MARK:
    
    @objc func countdown() {
        currentCountdownTime!--
        delegate.updateHighScore()

        if currentCountdownTime <= 0 {
            countdownTimer.invalidate()
            endGame()
        }
        
        println("countdown \(currentCountdownTime)")
    }
}
