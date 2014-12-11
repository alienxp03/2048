//
//  MenuViewController.swift
//  Swift 2048
//
//  Created by tokwan on 11/12/2014.
//  Copyright (c) 2014 alienxp03. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    var delegate: GameModeProtocol! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IBActions
    
    @IBAction func keepGoing(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func classicMode(sender: AnyObject) {
        self.delegate!.changeGameMode(.CLASSIC)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func timeMode(sender: AnyObject) {
        self.delegate!.changeGameMode(.TIME)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
