//
//  HyperlootDataSerializer.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation

class HyperlootDataSerializer {
    
    let path: URL
    
    init(path: URL) {
        self.path = path
    }
    
    func loadObject<T>(completion: @escaping (T?) -> Void) where T: Decodable {
        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let strongSelf = self else { return }
            
            guard let data = try? Data(contentsOf: strongSelf.path) else {
                completion(nil)
                return
            }
            
            do {
                let object: T = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(object)
                }
            } catch {
                print(error)
                completion(nil)
            }
        }
    }
    
    func save<T>(object: T, completion: @escaping (Bool) -> Void) where T: Encodable {
        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let strongSelf = self else { return }
            
            guard let json = try? JSONEncoder().encode(object) else {
                completion(false)
                return
            }
            
            do {
                try json.write(to: strongSelf.path, options: [.atomicWrite])
                DispatchQueue.main.async {
                    completion(true)
                }
            } catch {
                print(error)
                completion(false)
            }
        }
    }
}
