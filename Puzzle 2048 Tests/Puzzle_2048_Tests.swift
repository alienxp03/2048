//
//  Puzzle_2048_Tests.swift
//  Puzzle 2048 Tests
//
//  Created by tokwan on 13/12/2014.
//  Copyright (c) 2014 alienxp03. All rights reserved.
//

import UIKit
import XCTest

class Puzzle_2048_Tests: XCTestCase, GameModelProtocol {
    
    var gameModel: GameModel!
    var expectation: XCTestExpectation!
    
    override func setUp() {
        gameModel = GameModel(delegate: self)
    }
    
    /*
        Basic testing of the model
    */
    func testBasicModel(){
        gameModel.startGame()
        XCTAssertEqual(gameModel.gameBoardSize(), gameModel.startTiles, "Board size should match startTiles value")
    }
    
    /*
        Setup tests for the classic mode
    */
    func testClassicMode() {
        
        gameModel.startGame()
        
        var pow = 1
        var fakeGameBoard = Array<Array<Any>>()
        
        // Fill with the best possible move, from 2, 4 .. 65536
        for var i = 0; i < skGridSize; i++ {
            var columnArray = Array<Any>()
            for var j = 0; j < skGridSize; j++ {
                let tile = TileView()
                tile.value = Int(powf(Float(2), Float(pow++)))
                columnArray.append(tile)
            }
            fakeGameBoard.append(columnArray)
        }
        
        gameModel.gameBoard = fakeGameBoard
        
        XCTAssertFalse(gameModel.movePossible(), "No more possible move")
        XCTAssertEqual(gameModel.gameState, GameState.GAMEOVER, "Game should be over")
    }
    
    /*
        Setup tests for the step mode
    */
    func testStepMode() {
        // Move one more step than it should
        let movedStep = gameModel.maxSteps + 1
        
        gameModel.startGame()
        gameModel.gameMode = .STEP
        
        for i in 1...movedStep {
            gameModel.randomMove()
        }
        
        XCTAssertFalse(gameModel.movePossible(), "No more possible move")
        XCTAssertEqual(gameModel.gameState, GameState.GAMEOVER, "Game should be over")
    }
    
    /*
        Setup tests for the time mode
    */
    func testTimeMode() {
        gameModel.startGame()
        gameModel.gameMode = .TIME
        
        let delegate: FunAndTimeModeProtocol = gameModel
        
        expectation = expectationWithDescription("Time Mode: Game should already be over by now")
        
        // We can't really test the game from the start
        // We just assume to resume the game
        var resumeTime: NSTimeInterval = 2
        delegate.funAndTimeModeResumeGame(Int(resumeTime))
        
        // Don't be time Nazi, add 1 sec to for possible compiler testing delay
        resumeTime += 1
        waitForExpectationsWithTimeout(resumeTime, handler: nil)
    }
    
    /*
        Test tiles movement
    */
    func testTilesMovement() {
        
        // Board                                            Output board (with one RANDOM tile)
        //                ->  gameModel.move(moveUp)  ->
        // 2  0  0  0                                       4  0  0  0
        // 2  0  0  0                                       8  0  0  0
        // 4  0  0  0                                       0  0  0  0
        // 4  0  0  0                                       0  0  0  2
        
        gameModel.emptyGameBoard()
        gameModel.addTileAtColumn(TileView(value: 2), column: 0, row: 0)
        gameModel.addTileAtColumn(TileView(value: 2), column: 0, row: 1)
        gameModel.addTileAtColumn(TileView(value: 4), column: 0, row: 2)
        gameModel.addTileAtColumn(TileView(value: 4), column: 0, row: 3)
        gameModel.move(MoveUp)
        
        if let tile = gameModel.gameBoard[0][0] as? TileView {
            XCTAssertEqual(tile.value, 4, "This tile should merge")
        } else {
            XCTAssert(false, "Tile should not be empty")
        }
        
        if let tile = gameModel.gameBoard[0][1] as? TileView {
            XCTAssertEqual(tile.value, 8, "This tile should merge")
        } else {
            XCTAssert(false, "Tile should not be empty")
        }
        
        XCTAssertEqual(gameModel.gameBoardSize(), 3, "Game board should be filled with 3 tiles only")
        
        // End of board
        
        
        // Board                                            Output board (with one RANDOM tile)
        //                ->  gameModel.move(moveDown)  ->
        // 2  0  0  0                                       0  0  0  0
        // 2  0  0  0                                       0  0  0  0
        // 4  0  0  0                                       4  0  0  0
        // 4  0  0  0                                       8  0  0  2
        
        gameModel.emptyGameBoard()
        gameModel.addTileAtColumn(TileView(value: 2), column: 0, row: 0)
        gameModel.addTileAtColumn(TileView(value: 2), column: 0, row: 1)
        gameModel.addTileAtColumn(TileView(value: 4), column: 0, row: 2)
        gameModel.addTileAtColumn(TileView(value: 4), column: 0, row: 3)
        gameModel.move(MoveDown)
        
        if let tile = gameModel.gameBoard[0][2] as? TileView {
            XCTAssertEqual(tile.value, 4, "This tile should merge")
        } else {
            XCTAssert(false, "Tile should not be empty")
        }
        
        if let tile = gameModel.gameBoard[0][3] as? TileView {
            XCTAssertEqual(tile.value, 8, "This tile should merge")
        } else {
            XCTAssert(false, "Tile should not be empty")
        }
        
        XCTAssertEqual(gameModel.gameBoardSize(), 3, "Game board should be filled with 3 tiles only")
        
        // End of board
        
        
        // Board                                            Output board (with one RANDOM tile)
        //                ->  gameModel.move(moveRight)  ->
        // 2  0  0  0                                       0  0  0  2
        // 2  0  0  0                                       0  0  0  2
        // 4  0  0  0                                       2  0  0  4
        // 4  0  0  0                                       0  0  0  4
        
        gameModel.emptyGameBoard()
        gameModel.addTileAtColumn(TileView(value: 2), column: 0, row: 0)
        gameModel.addTileAtColumn(TileView(value: 2), column: 0, row: 1)
        gameModel.addTileAtColumn(TileView(value: 4), column: 0, row: 2)
        gameModel.addTileAtColumn(TileView(value: 4), column: 0, row: 3)
        gameModel.move(MoveRight)
        
        if let tile = gameModel.gameBoard[3][0] as? TileView {
            XCTAssertEqual(tile.value, 2, "This tile should merge")
        } else {
            XCTAssert(false, "Tile should not be empty")
        }
        
        if let tile = gameModel.gameBoard[3][1] as? TileView {
            XCTAssertEqual(tile.value, 2, "This tile should merge")
        } else {
            XCTAssert(false, "Tile should not be empty")
        }
        if let tile = gameModel.gameBoard[3][2] as? TileView {
            XCTAssertEqual(tile.value, 4, "This tile should merge")
        } else {
            XCTAssert(false, "Tile should not be empty")
        }
        
        if let tile = gameModel.gameBoard[3][3] as? TileView {
            XCTAssertEqual(tile.value, 4, "This tile should merge")
        } else {
            XCTAssert(false, "Tile should not be empty")
        }
        
        XCTAssertEqual(gameModel.gameBoardSize(), 5, "Game board should be filled with 5 tiles only")
        
        // End of board
        
        // Board                                            Output board (with one RANDOM tile)
        //                ->  gameModel.move(moveLeft)  ->
        // 2  0  0  0                                       0  0  0  2
        // 2  0  0  0                                       0  0  0  2
        // 4  0  0  0                                       2  0  0  4
        // 4  0  0  0                                       0  0  0  4
        
        gameModel.emptyGameBoard()
        gameModel.addTileAtColumn(TileView(value: 2), column: 0, row: 0)
        gameModel.addTileAtColumn(TileView(value: 2), column: 0, row: 1)
        gameModel.addTileAtColumn(TileView(value: 4), column: 0, row: 2)
        gameModel.addTileAtColumn(TileView(value: 4), column: 0, row: 3)
        gameModel.move(MoveLeft)
        
        if let tile = gameModel.gameBoard[0][0] as? TileView {
            XCTAssertEqual(tile.value, 2, "This tile should merge")
        } else {
            XCTAssert(false, "Tile should not be empty")
        }
        
        if let tile = gameModel.gameBoard[0][1] as? TileView {
            XCTAssertEqual(tile.value, 2, "This tile should merge")
        } else {
            XCTAssert(false, "Tile should not be empty")
        }
        if let tile = gameModel.gameBoard[0][2] as? TileView {
            XCTAssertEqual(tile.value, 4, "This tile should merge")
        } else {
            XCTAssert(false, "Tile should not be empty")
        }
        
        if let tile = gameModel.gameBoard[0][3] as? TileView {
            XCTAssertEqual(tile.value, 4, "This tile should merge")
        } else {
            XCTAssert(false, "Tile should not be empty")
        }
        
        XCTAssertEqual(gameModel.gameBoardSize(), 4, "Game board should be filled with 4 tiles only")
        
        // End of board
    }
    
    // MARK: GameModelProtocol
    
    func gameOver() {
        // Expectation is only for the time mode
        if gameModel.gameMode == .TIME {
            // Time's up, fulfill the expectation
            expectation.fulfill()
        }
    }
    
    func stepMoved() {}
    
    func updateHighScore() {}
    
    func addTileAtPosition(tile: TileView, column: Int, row: Int) {}
    
    func moveTile(tile: TileView, oldX: NSInteger, oldY: NSInteger, newX: NSInteger, newY: NSInteger) {}
    
    func mergeTileAtIndex(oldTile: TileView, newTile: TileView, x: NSInteger, y: NSInteger, otherTileX: NSInteger, otherTileY: NSInteger) {}
    
}
