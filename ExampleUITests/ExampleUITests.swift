//
//  ExampleUITests.swift
//  ExampleUITests
//
//  Created by Alex Rupérez on 19/5/17.
//  Copyright © 2017 alexruperez. All rights reserved.
//

import XCTest
import LaunchScreenSnapshot

class ExampleUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        if #available(iOS 9.0, *) {
            XCUIApplication().launch()
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testStaticUnprotect() {
        LaunchScreenSnapshot.unprotect()
    }
    
}
