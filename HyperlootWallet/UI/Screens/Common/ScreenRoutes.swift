//
//  ScreenRoutes.swift
//  HyperlootWallet
//
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation

enum ScreenRoute: String {
    case startLoginFlow = "start_login_flow"
    case showEnterNicknameScreen = "show_enter_nickname_screen"
    case showEnterPasswordScreen = "show_enter_password_screen"
    case showEnterWalletKeysScreen = "show_enter_wallet_keys_screen"
    case showImportOrCreateScreen = "show_import_or_create_screen"
    
    case showWallet = "show_wallet"
    case showWalletAfterLoginFlow = "show_wallet_after_login"
    case showTransactions = "show_transactions"
    case showItemDetails = "show_item_details"
    
    case sendToken = "send_token"
}
