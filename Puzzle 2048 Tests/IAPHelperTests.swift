//
//  IAPHelperTests.swift
//  Puzzle 2048
//
//  Created by tokwan on 13/12/2014.
//  Copyright (c) 2014 alienxp03. All rights reserved.
//

import UIKit
import StoreKit
import XCTest

class IAPHelperTests: XCTestCase {

    func testRequestProductsWithCompletionHandler() {
        IAPHelper.sharedInstance.requestProductsWithCompletionHandler({
            (value: Bool, products: [SKProduct]?) in
                XCTAssertTrue(value, "The request should be successful")
                XCTAssertGreaterThan(products!.count, 1, "We should have iAP items in the store")
        })
    }
}
