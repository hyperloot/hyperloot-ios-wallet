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
        api.login(email: email, password: password, completion: { [weak self] (login: LoginResponse?, error) in
            guard let user = self?.createUserFrom(loginResponse: login) else {
                completion(nil, error)
                return
            }
            
            completion(user, nil)
        })
    }
    
    public func createUser(withEmail email: String, password: String, nickname: String, walletAddress: Address, completion: @escaping (HyperlootUser?, Error?) -> Void) {
        api.signup(email: email, password: password, nickname: nickname, walletAddress: walletAddress.description) { [weak self] (signup: SignupResponse?, error) in
            guard let signup = signup, signup.userId.isEmpty == false else {
                completion(nil, error)
                return
            }
            
            self?.login(email: signup.email, password: password, completion: completion)
        }
    }
    
    private func createUserFrom(loginResponse: LoginResponse?) -> HyperlootUser? {
        guard let login = loginResponse,
            let address = Address(string: login.walletAddress) else {
                return nil
        }
        
        let user = HyperlootUser(email: login.email,
                                 nickname: HyperlootNickname(name: login.nickname.nickname, identifier: login.nickname.identifier),
                                 walletAddress: address)
        save(user: user, to: userFilePath)
        self.user = user
        
        return user
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
