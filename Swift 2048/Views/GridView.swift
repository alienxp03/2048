//
//  Grid.swift
//  Swift 2048
//
//  Created by tokwan on 10/12/2014.
//  Copyright (c) 2014 alienxp03. All rights reserved.
//

import UIKit

protocol GridViewDelegate {
    func restartGameAfterRedraw(value: Bool)
}

class GridView: UIView {
    
    var columnWitdh:CGFloat!
    var columnHeight:CGFloat!
    var tileMarginVertical:CGFloat!
    var tileMarginHorizontal:CGFloat!
    
    // For animation
    let tilePopStartScale: CGFloat          = 0.1
    let tilePopMaxScale: CGFloat            = 1.1
    let tilePopDelay: NSTimeInterval        = 0.05
    let tileExpandTime: NSTimeInterval      = 0.18
    let tileContractTime: NSTimeInterval    = 0.08
    
    var noTile                              = NSNull()
    
    var delegate: GridViewDelegate!
    
    // MARK: Required
    override func drawRect(rect: CGRect) {
        setupBackground()
    }
    
    // MARK: 
    
    /*
        Calculate and draw the main board background
    */
    func setupBackground() {
        var tile = TileView()
        columnWitdh = tile.frame.size.width
        columnHeight = tile.frame.size.height
        
        tileMarginHorizontal = (frame.size.width - (CGFloat(gridSize) * columnWitdh)) / (CGFloat(gridSize) + 1)
        tileMarginVertical = (frame.size.height - (CGFloat(gridSize) * columnWitdh)) / (CGFloat(gridSize) + 1)
        
        var x:CGFloat = tileMarginHorizontal
        var y:CGFloat = tileMarginVertical
        
        for var i = 0; i < gridSize; i++ {
            x = tileMarginHorizontal
            
            for var j = 0; j < gridSize; j++ {
                var view = UIView(frame: CGRectMake(x, y, tile.frame.size.width, tile.frame.size.height))
                view.backgroundColor = UIColor(red: 0.682, green: 0.855, blue: 0.851, alpha: 1)
                addSubview(view)
                x += columnWitdh + tileMarginHorizontal
            }
            y += columnHeight + tileMarginVertical
        }
    }
    
    
    
    /*
        Given a tile row and column position, get the tile position in the GridView
    
        @return Position of the tile
    */
    func positionForColumn(column: NSInteger, row: NSInteger) -> CGPoint {
        let x = tileMarginHorizontal + CGFloat(column) * (tileMarginHorizontal + columnWitdh)
        let y = tileMarginVertical + CGFloat(row) * (tileMarginVertical + columnHeight)
        return CGPoint(x: x, y: y)
    }
    
    /*
        Add/create a tile at given position
    */
    func animateAddTileAtColumn(tile: TileView, column: NSInteger, row: NSInteger) {
        var position = positionForColumn(column, row: row)
        tile.frame = CGRectMake(position.x, position.y, tile.frame.width, tile.frame.height)
        tile.layer.setAffineTransform(CGAffineTransformMakeScale(tilePopStartScale, tilePopStartScale))
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
    
    /*
        Move a tile to a new position
    */
    func animateMoveTile(tile: TileView, oldX: NSInteger, oldY: NSInteger, newX: NSInteger, newY: NSInteger) {
        let newPosition = self.positionForColumn(newX, row: newY)
        
        UIView.animateWithDuration(0.2, animations: {
            tile.frame = CGRectMake(newPosition.x, newPosition.y, tile.frame.width, tile.frame.height)
        })
    }
    
    /*
        Merge two tiles together. After merge, we remove one of the tile from the view
    */
    func animateMergeTileAtIndex(oldTile: TileView, newTile: TileView, x: NSInteger, y: NSInteger, otherTileX: NSInteger, otherTileY: NSInteger) {
        // update the UI
        var otherTilePosition = positionForColumn(otherTileX, row: otherTileY)
        
        UIView.animateWithDuration(0.2, animations: {
                newTile.frame = CGRectMake(otherTilePosition.x, otherTilePosition.y, newTile.frame.width, newTile.frame.height)
                newTile.updateValueDisplay()
            }, completion: {
            (value: Bool) in
                oldTile.removeFromSuperview()
        })
    }
}
