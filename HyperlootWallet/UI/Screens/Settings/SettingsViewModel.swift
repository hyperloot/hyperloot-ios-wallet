//
//  SettingsViewModel.swift
//  HyperlootWallet
//

import Foundation

class SettingsViewModel {
    
    enum Settings {
        case email
        case address
        case network
        case exportPrivateKey
        case exportSeed
    }
    
    enum Action {
        case selectNetwork
        case exportPrivateKey(String)
        case exportSeed(String)
    }
    
    private lazy var settings: [Settings] = [.email, .address, .network, .exportPrivateKey, .exportSeed]
    
    private var presentations: [SettingsPresentation] {
        return settings.map { SettingsPresentation(settingsKey: settingsKey(for: $0),
                                                   settingsValue: settingsValue(for: $0),
                                                   selectable: canBeSelected(entry: $0)) }
    }
    
    private func settingsKey(for entry: Settings) -> String {
        switch entry {
        case .email:
            return "Email"
        case .address:
            return "Address"
        case .network:
            return "Network"
        case .exportPrivateKey:
            return "Export Private Key"
        case .exportSeed:
            return "Export Mnemonic (Seed) Phrase"
        }
    }
    
    private func settingsValue(for entry: Settings) -> String? {
        switch entry {
        case .email:
            return Hyperloot.shared.user?.email
        case .address:
            return Hyperloot.shared.user?.walletAddress.description
        case .network:
            return "Main"
        case .exportSeed, .exportPrivateKey:
            return nil
        }
    }
    
    private func canBeSelected(entry: Settings) -> Bool {
        switch entry {
        case .email, .address, .network:
            return false
        case .exportSeed, .exportPrivateKey:
            return true
        }
    }
    
    func numberOfSettingsEntries() -> Int {
        return presentations.count
    }
    
    func presentation(at index: Int) -> SettingsPresentation {
        return presentations[index]
    }
    
    func performAction(for index: Int, completion: @escaping (Action?) -> Void) {
        let entry = settings[index]

        switch entry {
        case .email, .address:
            completion(nil)
        case .network:
            completion(.selectNetwork)
        case .exportPrivateKey:
            exportPrivateKey(completion: completion)
        case .exportSeed:
            exportMnemonicPhrase(completion: completion)
        }
    }
    
    private func exportPrivateKey(completion: @escaping (Action?) -> Void) {
        guard let user = Hyperloot.shared.user else {
            completion(nil)
            return
        }
        
        Hyperloot.shared.exportPrivateKey(user: user) { (value) in
            guard let value = value else {
                completion(nil)
                return
            }
            completion(.exportPrivateKey(value))
        }
    }
    
    private func exportMnemonicPhrase(completion: @escaping (Action?) -> Void) {
        guard let user = Hyperloot.shared.user else {
            completion(nil)
            return
        }
        
        Hyperloot.shared.exportMnemonicPhrase(user: user) { (value) in
            guard let value = value else {
                completion(nil)
                return
            }
            completion(.exportSeed(value))
        }
    }
}
