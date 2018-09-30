//
//  ScreenRoutes.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 9/18/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

enum ScreenRoute: String {
    case startLoginFlow = "start_login_flow"
    case showEnterPasswordScreen = "show_enter_password_screen"
    case showEnterWalletKeysScreen = "show_enter_wallet_keys_screen"
    case showImportOrCreateScreen = "show_import_or_create_screen"
    
    case showWallet = "show_wallet"
    case showWalletAfterLoginFlow = "show_wallet_after_login"
}
