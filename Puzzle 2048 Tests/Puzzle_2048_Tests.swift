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
        for var i = 0; i < gridSize; i++ {
            var columnArray = Array<Any>()
            for var j = 0; j < gridSize; j++ {
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
        
        let delegate: TimeModeProtocol = gameModel
        
        expectation = expectationWithDescription("Time Mode: Game should already be over by now")
        
        // We can't really test the game from the start
        // We just resume the game
        var resumeTime: NSTimeInterval = 2
        delegate.timeModeResumeGame(Int(resumeTime))
        
        // Don't be time Nazi, add 1 sec to resumeTime
        resumeTime += 1
        waitForExpectationsWithTimeout(resumeTime, handler: nil)
    }
    
    
    // MARK: GameModelProtocol
    
    func gameOver() {
        // Expectation is only for the time mode
        if gameModel.gameMode == .TIME {
            expectation.fulfill()
        }
    }
    
    func stepMoved() {
    }
    
    func updateHighScore() {
    }
    
    func addTileAtPosition(tile: TileView, column: Int, row: Int) {
    }
    
    func moveTile(tile: TileView, oldX: NSInteger, oldY: NSInteger, newX: NSInteger, newY: NSInteger) {
    }
    
    func mergeTileAtIndex(oldTile: TileView, newTile: TileView, x: NSInteger, y: NSInteger, otherTileX: NSInteger, otherTileY: NSInteger) {
    }
    
}
