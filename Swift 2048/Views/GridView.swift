//
//  Grid.swift
//  Swift 2048
//
//  Created by tokwan on 10/12/2014.
//  Copyright (c) 2014 alienxp03. All rights reserved.
//

import UIKit

let gridSize    = 4
let startTiles  = 2

class GridView: UIView {
    var columnWitdh:CGFloat!
    var columnHeight:CGFloat            = 0.0
    var tileMarginVertical:CGFloat      = 0.0
    var tileMarginHorizontal:CGFloat    = 0.0
    
    // For animation
    let tilePopStartScale: CGFloat      = 0.1
    let tilePopMaxScale: CGFloat        = 1.1
    let tilePopDelay: NSTimeInterval    = 0.05
    let tileExpandTime: NSTimeInterval  = 0.18
    let tileContractTime: NSTimeInterval = 0.08
    
    var gridArray: Array<Array<Any>>!
    var noTile                          = NSNull()
    
    // keep the score
    var score: NSInteger                = 0
    
    // MARK: Required
    override func drawRect(rect: CGRect) {
        setupBackground()
        
        gridArray = Array<Array<Any>>()
        
        for var i = 0; i < gridSize; i++ {
            var columnArray = Array<Any>()
            for var j = 0; j < gridSize; j++ {
                columnArray.append(noTile)
            }
            gridArray.append(columnArray)
        }
        
        spawnStartTiles()
        
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "swipeLeft")
        swipeLeft.direction = .Left
        addGestureRecognizer(swipeLeft)
        
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "swipeRight")
        swipeRight.direction = .Right
        addGestureRecognizer(swipeRight)
        
        var swipeUp = UISwipeGestureRecognizer(target: self, action: "swipeUp")
        swipeUp.direction = .Up
        addGestureRecognizer(swipeUp)
        
        var swipeDown = UISwipeGestureRecognizer(target: self, action: "swipeDown")
        swipeDown.direction = .Down
        addGestureRecognizer(swipeDown)
    }
    
    // MARK: 
    
    func setupBackground() {
        var tile = TileView()
        columnWitdh = tile.frame.size.width
        columnHeight = tile.frame.size.height
        
        tileMarginHorizontal = (frame.size.width - (CGFloat(gridSize) * columnWitdh)) / (CGFloat(gridSize) + 1)
        tileMarginVertical = (frame.size.height - (CGFloat(gridSize) * columnWitdh)) / (CGFloat(gridSize) + 1)
        
        var x = tileMarginHorizontal
        var y = tileMarginVertical
        
        for var i = 0; i < gridSize; i++ {
            x = tileMarginHorizontal
            
            for var j = 0; j < gridSize; j++ {
                var view = UIView(frame: CGRectMake(x, y, tile.frame.size.width, tile.frame.size.height))
                view.backgroundColor = .grayColor()
                addSubview(view)
                x += columnWitdh + tileMarginHorizontal
            }
            y += columnHeight + tileMarginVertical
        }
    }
    
    func positionForColumn(column: NSInteger, row: NSInteger) -> CGPoint {
        let x = tileMarginHorizontal + CGFloat(column) * (tileMarginHorizontal + columnWitdh)
        let y = tileMarginVertical + CGFloat(row) * (tileMarginVertical + columnHeight)
        return CGPoint(x: x, y: y)
    }
    
    func addTileAtColumn(column: NSInteger, row: NSInteger) {
        var position = positionForColumn(column, row: row)
        var tile = TileView()
        tile.frame = CGRectMake(position.x, position.y, tile.frame.width, tile.frame.height)
        gridArray[column][row] = tile
        tile.layer.setAffineTransform(CGAffineTransformMakeScale(tilePopStartScale, tilePopStartScale))
//        tile
        addSubview(tile)
        
        // Add to board
        UIView.animateWithDuration(tileExpandTime, delay: tilePopDelay, options: UIViewAnimationOptions.TransitionNone,
            animations: { () -> Void in
                // Make the tile 'pop'
                tile.layer.setAffineTransform(CGAffineTransformMakeScale(self.tilePopMaxScale, self.tilePopMaxScale))
            },
            completion: { (finished: Bool) -> Void in
                // Shrink the tile after it 'pops'
                UIView.animateWithDuration(self.tileContractTime, animations: { () -> Void in
                    tile.layer.setAffineTransform(CGAffineTransformIdentity)
                })
        })
    }
    
    func spawnRandomTile() {
        var spawned = false
        while !spawned {
            var randomColumn = Int(arc4random_uniform(UInt32(gridSize)))
            var randomRow = Int(arc4random_uniform(UInt32(gridSize)))
            var positionFree = (gridArray[randomColumn][randomRow] as? NSNull == noTile)
            if positionFree {
                addTileAtColumn(randomColumn, row: randomRow)
                spawned = true
            }
        }
    }
    
    func spawnStartTiles() {
        for var i = 0; i < startTiles; i++ {
            spawnRandomTile()
        }
    }
    
    // MARK: Swipe actions
    
    func swipeLeft() {
        move(CGPoint(x: -1, y: 0))
    }
    
    func swipeRight() {
        move(CGPoint(x: 1, y: 0))
    }
    
    func swipeUp() {
        move(CGPoint(x: 0, y: -1))
    }
    
    func swipeDown() {
        move(CGPoint(x: 0, y: 1))
    }

    // MARK: Move tiles
    
    func move(direction: CGPoint) {
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
                var tile = gridArray[currentX][currentY] as? TileView
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
                    var otherTile = gridArray[otherTileX][otherTileY] as TileView
                    // compare value of other tile and also check if the other tile has been merged this round
                    if tile?.value == otherTile.value && !otherTile.mergedThisRound {
                        // merge tiles
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
            nextRound()
        }
    }
    
    func indexValid(x: NSInteger, y: NSInteger) -> Bool {
        var indexValid = true
        indexValid &= x >= 0
        indexValid &= y >= 0
        
        if indexValid {
            indexValid &= x < gridArray.count
            if indexValid {
                indexValid &= y < gridArray[x].count
            }
        }
        return indexValid
    }
    
    func moveTile(tile: TileView, oldX: NSInteger, oldY: NSInteger, newX: NSInteger, newY: NSInteger) {
        gridArray[newX][newY] = gridArray[oldX][oldY]
        gridArray[oldX][oldY] = noTile
        let newPosition = self.positionForColumn(newX, row: newY)
        
//        println("pos \(newX) \(newY) \(oldX) \(oldY)")
        
        UIView.animateWithDuration(0.2, animations: {
            tile.frame = CGRectMake(newPosition.x, newPosition.y, tile.frame.width, tile.frame.height)
        })
    }
    
    func indexValidAndUnoccupied(x: NSInteger, y: NSInteger) -> Bool {
        var indexValid = self.indexValid(x, y: y)
        if !indexValid {
            return false
        }
        var unoccupied = (gridArray[x][y] as? NSNull == noTile)
        return unoccupied
    }
    
    func mergeTileAtIndex(x: NSInteger, y: NSInteger, otherTileX: NSInteger, otherTileY: NSInteger) {
        // update game data
        var mergedTile = gridArray[x][y] as TileView
        var otherTile = gridArray[otherTileX][otherTileY] as TileView
        self.score += mergedTile.value + otherTile.value
        otherTile.value *= 2
        otherTile.mergedThisRound = true
        gridArray[x][y] = noTile
        
        // update the UI
        var otherTilePosition = positionForColumn(otherTileX, row: otherTileY)
        NSNotificationCenter.defaultCenter().postNotificationName("UpdateScore", object: nil)
        
        UIView.animateWithDuration(0.2, animations: {
                otherTile.frame = CGRectMake(otherTilePosition.x, otherTilePosition.y, otherTile.frame.width, otherTile.frame.height)
                otherTile.updateValueDisplay()
            }, completion: {
            (value: Bool) in
                mergedTile.removeFromSuperview()
        })
    }
    
    func nextRound() {
        spawnRandomTile()
        
        for var i = 0; i < gridSize; i++ {
            for var j = 0; j < gridSize; j++ {
                let tile = gridArray[i][j] as? TileView
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
    
    func movePossible() -> Bool {
        for var i = 0; i < gridSize; i++ {
            for var j = 0; j < gridSize; j++ {
                var tile = gridArray[i][j] as? TileView
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
        
        return false
    }
    
    func tileForIndex(x: NSInteger, y: NSInteger) -> Any {
        if !indexValid(x, y: y) {
            return noTile
        } else {
            return gridArray[x][y]
        }
    }
    
    func endGame() {
        var highScore = NSUserDefaults.standardUserDefaults().objectForKey("highScore") as? NSInteger
        
        if score > highScore || highScore == nil {
            highScore = score
            NSUserDefaults.standardUserDefaults().setObject(highScore, forKey: "highScore")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            NSNotificationCenter.defaultCenter().postNotificationName("UpdateHighScore", object: nil)
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("GameOver", object: nil)
    }
    
    
}
