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
    
    public init() {
        user = loadUser(from: userFilePath)
    }
    
    public func createUser(withEmail email: String, nickname: HyperlootNickname, walletAddress: Address) {
        let user = HyperlootUser(email: email, nickname: nickname, walletAddress: walletAddress)
        save(user: user, to: userFilePath)
        
        self.user = user
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
