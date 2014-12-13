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

let MoveLeft                = CGPoint(x: -1, y: 0)
let MoveRight               = CGPoint(x: 1, y: 0)
let MoveUp                  = CGPoint(x: 0, y: -1)
let MoveDown                = CGPoint(x: 0, y: 1)

enum GameModeType {
    case CLASSIC, TIME, STEP, FUN
    
    func description () -> String {
        switch self {
        case CLASSIC:
            return "CLASSIC"
        case TIME:
            return "TIME"
        case STEP:
            return "STEP"
        case FUN:
            return "FUN"
        }
    }
}

enum GameState {
    case PAUSE, RUNNING, GAMEOVER
    
    func description () -> String {
        switch self {
        case PAUSE:
            return "PAUSE"
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

// Only for Fun/Time Mode
protocol FunAndTimeModeProtocol {
    func funAndTimeModeStartGame()
    func funAndTimeModePauseGame()
    func funAndTimeModeResumeGame(time: Int)
    func funAndTimeModeGameOver()
}

class ConstantAndPrococols: NSObject {
   
}
