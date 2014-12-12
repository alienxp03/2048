//
//  GameModel.swift
//  Swift 2048
//
//  Created by tokwan on 11/12/2014.
//  Copyright (c) 2014 alienxp03. All rights reserved.
//

import UIKit

let kStepModeNotification = "kStepModeNotification"

enum GameModeType {
    case CLASSIC, TIME, STEP
}

class GameModel {
    var score = 0
    var gameMode: GameModeType  = .CLASSIC
    let maxCountdownTime        = 10
    let maxSteps                = 10
    
    class var sharedInstance: GameModel {
        struct Static {
            static let instance: GameModel = GameModel()
        }
        return Static.instance
    }
}
