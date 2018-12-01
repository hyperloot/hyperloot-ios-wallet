//
//  UserManager.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 9/17/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import TrustCore

class UserManager {
    
    struct Constants {
        static let userFilename = "hlusr.hl"
    }
    
    private lazy var userFilePath: URL = {
        let docsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return URL(fileURLWithPath: docsDirectory + Constants.userFilename)
    } ()
    
    public private(set) var user: HyperlootUser?
    private var api: HyperlootAPI
    
    public init(api: HyperlootAPI) {
        self.api = api
        user = loadUser(from: self.userFilePath)
    }
    
    func canRegister(email: String, completion: @escaping (Bool) -> Void) {
        api.canRegister(email: email) { (result, _) in
            completion(result ?? false)
        }
    }
    
    func login(email: String, password: String, completion: @escaping (HyperlootUser?, Error?) -> Void) {
        // TODO: make an API call to Hyperloot backend: /login
        guard let address = Address(string: "0xa809d363a66c576a2a814cdbfefc107c600a55f0") else {
            completion(nil, nil)
            return
        }
        let user = HyperlootUser(email: email, nickname: HyperlootNickname(name: email, identifier: 1), walletAddress: address)
        save(user: user, to: userFilePath)
        self.user = user
        completion(user, nil)
    }
    
    public func createUser(withEmail email: String, nickname: String, walletAddress: Address, completion: @escaping (HyperlootUser?, Error?) -> Void) {
        // TODO: make API call to Hyperloot backend: /signup
        let user = HyperlootUser(email: email, nickname: HyperlootNickname(name: nickname, identifier: 1), walletAddress: walletAddress)
        save(user: user, to: userFilePath)
        
        self.user = user
        completion(user, nil)
    }
    
    // MARK: - Private
    private func save(user: HyperlootUser, to url: URL) {
        guard let json = try? JSONEncoder().encode(user) else {
            return
        }
        try? json.write(to: url, options: [.atomicWrite])
    }
    
    private func loadUser(from url: URL) -> HyperlootUser? {
        guard let data = try? Data(contentsOf: url),
            let user = try? JSONDecoder().decode(HyperlootUser.self, from: data) else {
                return nil
        }
        
        return user
    }
}
