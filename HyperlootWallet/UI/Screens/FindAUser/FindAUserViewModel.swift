//
//  FindAUserViewModel.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation

class FindAUserViewModel {
    
    struct Constants {
        static let minTextLength = 3
    }
    
    var searchOperation: Cancelable? = nil
    var users: [HyperlootUserSuggestion] = []
    var page: Int = 1
    
    public func didChangeSearch(text: String?, completion: @escaping () -> Void) {
        guard let text = text else {
            cancelSearch()
            completion()
            return
        }
        
        reset()
        searchUsers(nickname: text, completion: completion)
    }
    
    public func numberOfUsers() -> Int {
        return users.count
    }
    
    public func presentation(at index: Int) -> FindUserPresentation {
        let user = users[index]
        return FindUserPresentation(userNickname: "\(user.nickname)#\(user.identifier)",
            walletAddress: user.walletAddress)
    }
    
    // MARK: - Private
    
    private func reset() {
        users.removeAll()
        page = 0
    }
    
    private func cancelSearch() {
        if let previousSearchOperation = searchOperation {
            previousSearchOperation.cancel()
            searchOperation = nil
        }
    }
    
    private func searchUsers(nickname: String, completion: @escaping () -> Void) {
        cancelSearch()
        
        guard nickname.count >= Constants.minTextLength else {
            completion()
            return
        }
        
        searchOperation = Hyperloot.shared.findUsers(nickname: nickname, page: page) { [weak self] (users, error) in
            if let newUsers = users {
                self?.users.append(contentsOf: newUsers)
            }
            completion()
            self?.searchOperation = nil
        }
    }
    
}
