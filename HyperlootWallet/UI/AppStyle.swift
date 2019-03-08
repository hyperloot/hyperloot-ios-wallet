//
//  AppAppearance.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import UIKit

class AppStyle {
    
    struct Colors {
        static let defaultBackground = UIColor(hex: 0x222730)
        static let orangeRedButton = UIColor(hex: 0xDE2264)
        static let darkContainer = UIColor(hex: 0x171B21)
        static let defaultText = UIColor(hex: 0xF3F6FC)
        static let disabledText = UIColor(hex: 0xF3F6FC, alpha: 0.5)
    }
    
    static func apply() {
        
        UINavigationBar.appearance().backgroundColor = Colors.defaultBackground
        UINavigationBar.appearance().barTintColor = Colors.defaultBackground
        UINavigationBar.appearance().tintColor = Colors.orangeRedButton
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: Colors.defaultText]
    }
    
}
