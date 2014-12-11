//
//  GameModel.swift
//  Swift 2048
//
//  Created by tokwan on 11/12/2014.
//  Copyright (c) 2014 alienxp03. All rights reserved.
//

import UIKit

enum GameModeType {
    case CLASSIC, TIME
}

class GameModel {
    var score = 0
    var mode: GameModeType = .CLASSIC
    var maxCountdownTime = 5
    
    class var sharedInstance: GameModel {
        struct Static {
            static let instance: GameModel = GameModel()
        }
        return Static.instance
    }
}
