//
//  URL+DocumentsPath.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation

extension URL {
    static func documentsPath(filename: String) -> URL {
        let docsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let docsDirectoryURL = URL(fileURLWithPath: docsDirectory)
        return docsDirectoryURL.appendingPathComponent(filename)
    }
}
