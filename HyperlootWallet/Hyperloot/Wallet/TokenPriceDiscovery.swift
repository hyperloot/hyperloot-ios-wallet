//
//  TokenPriceDiscovery.swift
//  HyperlootWallet
//
//  Copyright © 2019 Hyperloot DAO. All rights reserved.
//

import Foundation

class TokenPriceDiscovery {
    
    typealias Symbol = String
    
    struct Constants {
        static let priceDBFilename = "prices.hl"
        static let defaultCurrencyCode = "USD"
    }
    
    struct GetPricesRequest {
        let symbols: [Symbol]
    }
        
    let coinMarketCap: CoinMarketCap
    let config: HyperlootConfig
    private lazy var priceDBPath = URL.documentsPath(filename: Constants.priceDBFilename)
    private lazy var dataSerializer = HyperlootDataSerializer(path: self.priceDBPath)
    
    private var prices: [Symbol: HyperlootTokenPrice] = [:]
    private var isLocalStorageLoaded: Bool = false
    
    private var currencyCode: String {
        return Locale.current.currencyCode ?? Constants.defaultCurrencyCode
    }
    
    required init(config: HyperlootConfig) {
        self.config = config
        self.coinMarketCap = CoinMarketCap(apiKey: config.coinMarketCapAPIKey)
    }
    
    func coinMarketCapSymbols(tokens: [HyperlootToken]) -> [Symbol] {
        // Excluding ERC-721
        let symbols = tokens.map { $0.isERC721() == false ? $0.symbol : nil }.compactMap { $0 }
        return Array(Set(symbols))
    }
    
    func getLocalPrice(symbol: Symbol, completion: @escaping(HyperlootTokenPrice?) -> Void) {
        loadPrices { [weak self] in
            let price = self?.findPrice(forSymbol: symbol)
            completion(price)
        }
    }
    
    func getPrices(tokens: [HyperlootToken], completion: @escaping ([HyperlootTokenPrice]) -> Void) {
        loadPrices { [weak self] in
            self?.getAvailableSymbols(tokens: tokens) { (availableSymbols) in
                self?.getCoinMarketCapQuotes(symbols: availableSymbols, completion: completion)
            }
        }
    }
    
    //MARK: - Private methods
    private func getCoinMarketCapQuotes(symbols: [Symbol], completion: @escaping ([HyperlootTokenPrice]) -> Void) {
        coinMarketCap.quotes(symbols: symbols, convertToCurrency: currencyCode, completion: { [weak self] (response, error) in
            self?.process(response: response, completion: completion)
        })
    }
    
    private func getItemsPrices(tokens: [HyperlootToken]) -> [HyperlootTokenPrice] {
        let symbols = tokens.map { $0.isERC721() ? $0.symbol : nil }.compactMap { $0 }
        var itemPrices: [HyperlootTokenPrice] = []
        prices.forEach {
            guard symbols.contains($0.key) else { return }
            itemPrices.append($0.value)
        }
        return itemPrices
    }
    
    private func process(response: CoinMarketCapListResponse?, completion: @escaping ([HyperlootTokenPrice]) -> Void) {
        guard let responsePrices = response?.data else {
            completion([])
            return
        }
        
        var processedPrices: [HyperlootTokenPrice] = []
        responsePrices.values.forEach { (marketPrice) in
            guard let symbol = marketPrice.symbol, let quote = marketPrice.quote?[currencyCode] else { return }
            let tokenPrice = HyperlootTokenPrice(symbol: symbol,
                                                 price: quote.price ?? 0.0,
                                                 percentChange1h: quote.percentChange1h ?? 0.0,
                                                 percentChange24h: quote.percentChange24h ?? 0.0,
                                                 percentChange7d: quote.percentChange7d ?? 0.0)
            processedPrices.append(tokenPrice)
            prices[symbol] = tokenPrice
        }
        dataSerializer.save(object: prices) { (_) in
            completion(processedPrices)
        }
    }
    
    private func findPrice(forSymbol symbol: Symbol) -> HyperlootTokenPrice? {
        return prices[symbol]
    }
    
    private func getAvailableSymbols(tokens: [HyperlootToken], completion: @escaping ([Symbol]) -> Void) {
        let symbols = coinMarketCapSymbols(tokens: tokens)
        coinMarketCap.map(symbols: symbols, completion: { (response, error) in
            var availableSymbols: [Symbol] = symbols
            
            if let error = error {
                switch error {
                case .invalid(symbols: let symbols):
                    availableSymbols.removeAll(where: { (symbol) -> Bool in
                        return symbols.contains(symbol)
                    })
                case .general(code: _, message: _):
                    availableSymbols = []
                }
            }
            
            completion(availableSymbols)
        })
    }
    
    //MARK: - Storage
    private func loadPrices(completion: @escaping () -> Void) {
        guard isLocalStorageLoaded == false else {
            completion()
            return
        }
        dataSerializer.loadObject { [weak self] (prices: [Symbol: HyperlootTokenPrice]?) in
            self?.isLocalStorageLoaded = true
            guard let prices = prices else {
                completion()
                return
            }
            self?.prices = prices
        }
    }
    
    private func save(completion: @escaping () -> Void) {
        dataSerializer.save(object: prices) { (result) in
            completion()
        }
    }
}
