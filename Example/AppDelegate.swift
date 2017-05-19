//
//  AppDelegate.swift
//  Example
//
//  Created by Alex Rupérez on 19/5/17.
//  Copyright © 2017 alexruperez. All rights reserved.
//

import UIKit
import LaunchScreenSnapshot

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        LaunchScreenSnapshot.protect()
        return true
    }

}
