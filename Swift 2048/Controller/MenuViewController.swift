//
//  MenuViewController.swift
//  Swift 2048
//
//  Created by tokwan on 11/12/2014.
//  Copyright (c) 2014 alienxp03. All rights reserved.
//

import UIKit
import StoreKit

class MenuViewController: UIViewController {
    
    var delegate: GameModeProtocol!
    var productsIAP: [String: SKProduct]!

    override func viewDidLoad() {
        super.viewDidLoad()
        productsIAP = IAPHelper.sharedInstance.productList
        
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
    
    @IBAction func changeGameMode(sender: UIButton) {
        switch sender.titleLabel!.text! {
            case "CLASSIC MODE":
                self.delegate!.changeGameMode(.CLASSIC)
                self.dismissViewControllerAnimated(true, completion: nil)
            case "TIME MODE":
                if IAPHelper.sharedInstance.isProductPurchased(skTimeModeUnlockedIdentifier) {
                    self.delegate!.changeGameMode(.TIME)
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    let alertView = SIAlertView(title: "Unlock new mode!", andMessage: "Do you want to buy a new game mode?")
                    alertView.transitionStyle = SIAlertViewTransitionStyle.Fade
                    
                    alertView.addButtonWithTitle("Cancel", type: .Cancel, handler: nil)
                    
                    alertView.addButtonWithTitle("Buy mode", type: .Destructive, handler: {
                        (SIAlertViewHandler) in
                        IAPHelper.sharedInstance.buyProduct(self.productsIAP[skTimeModeUnlockedIdentifier]!)
                    })
                    
                    alertView.show()
                }
            case "STEP MODE":
                if IAPHelper.sharedInstance.isProductPurchased(skStepModeUnlockedIdentifier) {
                    self.delegate!.changeGameMode(.STEP)
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    let alertView = SIAlertView(title: "Unlock new mode!", andMessage: "Do you want to buy a new game mode?")
                    alertView.transitionStyle = SIAlertViewTransitionStyle.Fade
                    
                    alertView.addButtonWithTitle("Cancel", type: .Cancel, handler: nil)
                    
                    alertView.addButtonWithTitle("Buy mode", type: .Destructive, handler: {
                        (SIAlertViewHandler) in
                        IAPHelper.sharedInstance.buyProduct(self.productsIAP[skStepModeUnlockedIdentifier]!)
                    })
                    
                    alertView.show()
                }
            default: break
        }
    }
}
