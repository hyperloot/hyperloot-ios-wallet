# Hyperloot Wallet for iOS

Welcome to Hyperloot Wallet! 
Here you could find source code for Hyperloot Wallet - a wallet for your tokenized assets which aims at easy adoption to cryptocurrencies.

Project is in Swift, uses CocoaPods (run ```pod install``` after cloning this repo).

Core is based on libraries by TrustWallet

## UX 
![First UX version](https://raw.githubusercontent.com/hyperloot/hyperloot-ios-wallet/master/hyperloot-wallet-UX.png)

## Environments
|Provider|Testnet|Main|
|----------|--------|-------|
|Hyperloot API |api-testnet.hyperloot.net|api.hyperloot.net|
|Blockscout|Ropsten|Mainnet|
|OpenSea|Rinkeby|Mainnet|
|Infura|Ropsten, Rinkeby|Mainnet|

## App Config
You need to put your API URLs and API Keys to make the app work. Create a file HyperlootConfig+App.swift, copy-paste this extension and put your keys and URLs there.
The following information is also available as a comment in HyperlootConfig.swift
`
extension HyperlootConfig {  
    static func current(for appEnvironment: AppEnvironment) -> HyperlootConfig {  
        return HyperlootConfig(app: appEnvironment,  
                                        apiURL: <YOUR URL HERE>,  
                                  blockscout: <.mainnet or .ropsten>,  
                               infuraAPIKey: "<YOUR KEY HERE>")  
        }  
}
`

