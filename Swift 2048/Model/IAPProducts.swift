////
////  IAPProducts.swift
////  Puzzle 2048
////
////  Created by tokwan on 13/12/2014.
////  Copyright (c) 2014 alienxp03. All rights reserved.
////
//
//import UIKit
//import StoreKit
//
//class IAPProducts: NSObject {
////    var productIdentifiers: NSSet!
//    
//    class var sharedInstance: IAPProducts {
//        struct Static {
//            
//            static let instance: IAPProducts = IAPProducts( productIdentifiers: NSSet(objects: skTimeModeUnlockedIdentifier, skStepModeUnlockedIdentifier) )
//        }
//        return Static.instance
//    }
//    
//    init(productIdentifiers: NSSet) {
//        
//        self.productIdentifiers = productIdentifiers
//        purchasedProductIdentifiers = NSMutableSet()
//        productList = [String: SKProduct]()
//        super.init()
//        
//        for productIdentifier in productIdentifiers {
//            var identifier: String? = productIdentifier as AnyObject? as? String
//            let productPurchased = NSUserDefaults.standardUserDefaults().boolForKey(identifier!)
//            
//            if productPurchased {
//                purchasedProductIdentifiers.addObject(productIdentifier)
//            }
//        }
//        
//        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
//    }
//    
//}
