//
//  ConstantAndPrococols.swift
//  Puzzle 2048
//
//  Created by tokwan on 13/12/2014.
//  Copyright (c) 2014 alienxp03. All rights reserved.
//

import UIKit

let skGridSize              = 4
let skStepMoved             = "StepMoved"

enum GameModeType {
    case CLASSIC, TIME, STEP
    
    func description () -> String {
        switch self {
        case CLASSIC:
            return "CLASSIC"
        case TIME:
            return "TIME"
        case STEP:
            return "STEP"
        }
    }
}

enum GameState {
    case RUNNING, GAMEOVER
    
    func description () -> String {
        switch self {
        case RUNNING:
            return "RUNNING"
        case GAMEOVER:
            return "GAMEOVER"
        }
    }
}

protocol GameModelProtocol {
    // Only for step mode
    func stepMoved()
    
    // For all modes
    func updateHighScore()
    func gameOver()
    func addTileAtPosition(tile: TileView, column: Int, row: Int)
    func moveTile(tile: TileView, oldX: NSInteger, oldY: NSInteger, newX: NSInteger, newY: NSInteger)
    func mergeTileAtIndex(oldTile: TileView, newTile: TileView, x: NSInteger, y: NSInteger, otherTileX: NSInteger, otherTileY: NSInteger)
}

// Only for Time Mode
protocol TimeModeProtocol {
    func timeModeStartGame()
    func timeModePauseGame()
    func timeModeResumeGame(time: Int)
    func timeModeGameOver()
}

class ConstantAndPrococols: NSObject {
   
}
