//
//  ExportViewModel.swift
//  HyperlootWallet
//

import Foundation

enum ExportType {
    case privateKey
    case seedPhrase
}

class ExportViewModel {
    
    struct Presentation {
        let exportValueType: String
        let value: String
    }
    
    let type: ExportType
    let value: String
    
    var presentation: Presentation {
        switch type {
        case .privateKey:
            return Presentation(exportValueType: "Private Key", value: value)
        case .seedPhrase:
            return Presentation(exportValueType: "Mnemonic Phrase", value: value)
        }
    }
    
    required init(type: ExportType, value: String) {
        self.type = type
        self.value = value
    }
    
}
