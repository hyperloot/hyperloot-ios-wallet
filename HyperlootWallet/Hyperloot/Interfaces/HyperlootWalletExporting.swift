//
//  HyperlootWalletExporting.swift
//  HyperlootWallet
//

import Foundation

protocol HyperlootWalletExporting {
    func exportPrivateKey(user: HyperlootUser, completion: @escaping (String?) -> Void)
    func exportMnemonicPhrase(user: HyperlootUser, completion: @escaping (String?) -> Void)
}
