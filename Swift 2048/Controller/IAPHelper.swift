//
//  IAPHelper.swift
//  s2048
//
//  Created by tokwan on 12/12/2014.
//  Copyright (c) 2014 alienxp03. All rights reserved.
//

import UIKit
import StoreKit

let skTimeModeUnlockedIdentifier = "com.alienxp03.puzzle2048.timemode"
let skStepModeUnlockedIdentifier = "com.alienxp03.puzzle2048.stepmode"
let skStepMoved                  = "StepMoved"

typealias RequestProductsCompletionHandler = (success: Bool, products: [SKProduct]?) -> Void

class IAPHelper: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    var isModeUnlocked: Bool!
    var productsRequest: SKProductsRequest!
    var completionHandler: RequestProductsCompletionHandler!
    var productIdentifiers: NSSet!
    var productList: [String: SKProduct]!
    var purchasedProductIdentifiers: NSMutableSet!
    
    class var sharedInstance: IAPHelper {
        struct Static {
            
            static let instance: IAPHelper = IAPHelper( productIdentifiers: NSSet(objects: skTimeModeUnlockedIdentifier, skStepModeUnlockedIdentifier) )
        }
        return Static.instance
    }
    
    init(productIdentifiers: NSSet) {
        
        self.productIdentifiers = productIdentifiers
        purchasedProductIdentifiers = NSMutableSet()
        productList = [String: SKProduct]()
        super.init()
        
        for productIdentifier in productIdentifiers {
            var identifier: String? = productIdentifier as AnyObject? as? String
            let productPurchased = NSUserDefaults.standardUserDefaults().boolForKey(identifier!)
            
            if productPurchased {
                purchasedProductIdentifiers.addObject(productIdentifier)
            }
        }
        
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }
    
    func requestProductsWithCompletionHandler(completionHandler: RequestProductsCompletionHandler) {
        self.completionHandler = completionHandler
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        productsRequest = nil
        
        if response.products.count > 0 {
            let products = response.products as [SKProduct]
            for product in products {
                productList[product.productIdentifier] = product
            }
            completionHandler(success: true, products: products)
        } else {
            completionHandler(success: true, products: nil)
        }
        
        completionHandler = nil
    }
    
    func request(request: SKRequest!, didFailWithError error: NSError!) {
        println("Error \(error)")
        
        productsRequest = nil
        completionHandler(success: true, products: nil)
        completionHandler = nil
    }
    
    func isProductPurchased(productIdentifier: String) -> Bool {
        return purchasedProductIdentifiers.containsObject(productIdentifier)
    }
    
    func buyProduct(product: SKProduct) {
        var payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        for transaction in transactions as [SKPaymentTransaction] {
            switch transaction.transactionState {
            case .Purchased:
                completeTransaction(transaction)
            case .Restored:
                restoreTransaction(transaction)
            case .Failed:
                failedTransaction(transaction)
            default:
                break
            }
        }
    }
    
    func completeTransaction(transaction: SKPaymentTransaction){
        provideContentForProductIdentifier(transaction.payment.productIdentifier)
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
    
    func restoreTransaction(transaction: SKPaymentTransaction){
        provideContentForProductIdentifier(transaction.originalTransaction.payment.productIdentifier)
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
    
    func failedTransaction(transaction: SKPaymentTransaction){
        
        if transaction.error.code != SKErrorPaymentCancelled {
            println("Error \(transaction.error.localizedDescription)")
        }
        
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
    
    func provideContentForProductIdentifier(productIdentifier: String) {
        purchasedProductIdentifiers.addObject(productIdentifier)
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: productIdentifier)
        NSUserDefaults.standardUserDefaults().synchronize()
//        NSNotificationCenter.defaultCenter().postNotificationName(ksIAPHelperProductPurchasedNotification, object: productIdentifier, userInfo: nil)
    }
}
