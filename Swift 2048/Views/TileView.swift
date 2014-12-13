//
//  Tile.swift
//  Swift 2048
//
//  Created by tokwan on 10/12/2014.
//  Copyright (c) 2014 alienxp03. All rights reserved.
//

import UIKit

let tileSize:CGFloat = 70

class TileView: UIView {
    
    var textLabel: UILabel
    var value: NSInteger
    var mergedThisRound: Bool

    override func drawRect(rect: CGRect) {
        updateValueDisplay()
        addSubview(textLabel)
    }
    
    override init() {
        textLabel = UILabel(frame: CGRectMake(0, 0, tileSize, tileSize))
        value = (Int(arc4random_uniform(2)) + 1) * 2
        textLabel.textAlignment = .Center
        textLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 32)
        mergedThisRound = false
        super.init(frame: CGRectMake(0, 0, tileSize, tileSize))
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    // MARK: Update label
    func updateValueDisplay() {
        textLabel.text = String(value)
        textLabel.backgroundColor = tileColor(value)
    }
    
    // Provide a tile color for a given value
    func tileColor(value: Int) -> UIColor {
        switch value {
        case 2:
            return UIColor(red: 238.0/255.0, green: 228.0/255.0, blue: 218.0/255.0, alpha: 1.0)
        case 4:
            return UIColor(red: 237.0/255.0, green: 224.0/255.0, blue: 200.0/255.0, alpha: 1.0)
        case 8:
            return UIColor(red: 242.0/255.0, green: 177.0/255.0, blue: 121.0/255.0, alpha: 1.0)
        case 16:
            return UIColor(red: 245.0/255.0, green: 149.0/255.0, blue: 99.0/255.0, alpha: 1.0)
        case 32:
            return UIColor(red: 246.0/255.0, green: 124.0/255.0, blue: 95.0/255.0, alpha: 1.0)
        case 64:
            return UIColor(red: 246.0/255.0, green: 94.0/255.0, blue: 59.0/255.0, alpha: 1.0)
        case 128, 256, 512, 1024, 2048:
            return UIColor(red: 237.0/255.0, green: 207.0/255.0, blue: 114.0/255.0, alpha: 1.0)
        default:
            return UIColor.whiteColor()
        }
    }

}
