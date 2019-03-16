//
//  AppManager.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import UIKit

import Fabric
import Crashlytics

class AppManager {
    
    static func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        AppStyle.apply()
        Fabric.with([Crashlytics.self])
    }
    
}
