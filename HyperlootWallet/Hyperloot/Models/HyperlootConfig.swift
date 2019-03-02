//
//  HyperlootConfig.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation

struct HyperlootConfig {
    let app: AppEnvironment
    let apiURL: String
    let blockscout: Blockscout.Environment
    let infuraAPIKey: String
    let openSea: OpenSea.Environment
    let openSeaAPIKey: String
    let coinMarketCapAPIKey: String
}

// PLEASE UNCOMMENT, MOVE THIS EXTENSION TO "HyperlootConfig+App.swift" AND PUT YOUR KEYS
// APP: The main configuration of the app: .mainnet or .testnet
// API URL: Hyperloot API URL
// Blockscout: Configuration of Blockscout: .mainnet or .ropsten
// Infura API Key: Your Infura key which could be found at the end of Infura endpoint from the dashboard
/*
extension HyperlootConfig {
    static func current(for appEnvironment: AppEnvironment) -> HyperlootConfig {
        return HyperlootConfig(app: <.mainnet or .testnet>,
                               apiURL: <YOUR URL HERE>,
                               blockscout: <.mainnet or .ropsten>,
                               infuraAPIKey: "<YOUR KEY HERE>")

    }
}
*/
