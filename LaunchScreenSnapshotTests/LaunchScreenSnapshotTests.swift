//
//  LaunchScreenSnapshotTests.swift
//  LaunchScreenSnapshotTests
//
//  Created by Alex Rupérez on 19/5/17.
//  Copyright © 2017 alexruperez. All rights reserved.
//

import XCTest
@testable import LaunchScreenSnapshot

class LaunchScreenSnapshotTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testApplicationWillResignActive() {
        let window = UIWindow()
        let view = UIView()
        let notificationCenter = NotificationCenter.default
        let launchScreenSnapshot = LaunchScreenSnapshot(notificationCenter: notificationCenter)
        launchScreenSnapshot.window = window
        launchScreenSnapshot.protect(with: view)
        XCTAssertFalse(window.subviews.contains(view))
        notificationCenter.post(name: .UIApplicationWillResignActive, object: nil)
        XCTAssertTrue(window.subviews.contains(view))
    }

    func testApplicationDidBecomeActive() {
        let window = UIWindow()
        let view = UIView()
        let notificationCenter = NotificationCenter.default
        let launchScreenSnapshot = LaunchScreenSnapshot(notificationCenter: notificationCenter)
        launchScreenSnapshot.window = window
        XCTAssertFalse(window.subviews.contains(view))
        launchScreenSnapshot.protect(with: view, force: true)
        notificationCenter.post(name: .UIApplicationDidBecomeActive, object: nil)
        XCTAssertTrue(window.subviews.contains(view))
    }

    func testApplicationWillEnterForeground() {
        let window = UIWindow()
        let view = UIView()
        let notificationCenter = NotificationCenter.default
        let launchScreenSnapshot = LaunchScreenSnapshot(notificationCenter: notificationCenter)
        launchScreenSnapshot.window = window
        launchScreenSnapshot.protect(with: view)
        XCTAssertFalse(window.subviews.contains(view))
        notificationCenter.post(name: .UIApplicationWillResignActive, object: nil)
        XCTAssertTrue(window.subviews.contains(view))
        notificationCenter.post(name: .UIApplicationWillEnterForeground, object: nil)
        XCTAssertFalse(window.subviews.contains(view))
    }

    func testStaticProtectUnprotect() {
        let window = UIWindow()
        let view = UIView()
        let launchScreenSnapshot = LaunchScreenSnapshot.protect(with: view)
        launchScreenSnapshot.window = window
        XCTAssertFalse(window.subviews.contains(view))
        NotificationCenter.default.post(name: .UIApplicationWillResignActive, object: nil)
        XCTAssertTrue(window.subviews.contains(view))
        LaunchScreenSnapshot.unprotect()
        XCTAssertFalse(window.subviews.contains(view))
    }

    func testViewFromStoryboard() {
        let window = UIWindow()
        let launchScreenSnapshot = LaunchScreenSnapshot(bundle: Bundle(identifier: "com.alexruperez.LaunchScreenSnapshot.Example")!)
        launchScreenSnapshot.window = window
        launchScreenSnapshot.protect()
        NotificationCenter.default.post(name: .UIApplicationWillResignActive, object: nil)
        XCTAssertGreaterThan(window.subviews.count, 0)
    }
    
}
