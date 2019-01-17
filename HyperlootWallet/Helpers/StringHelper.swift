//
//  StringHelper.swift
//  HyperlootWallet
//
//  Created by Valery Vaskabovich on 9/24/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import UIKit
import Foundation

class EmailValidator {
    
    public static func isValid(email: String?) -> Bool {
        guard let email = email else {
            return false
        }
        
        // Reference : http://www.regular-expressions.info/email.html
        let emailRegex = "[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:(?=[a-zA-Z0-9-]{1,63}\\.)[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\\.)+(?=[a-zA-Z0-9-]{1,4}\\z)[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?"
        
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: email)
    }
    
}

class BalanceFormatter {
    
    enum TransactionAmount {
        case positive(value: String)
        case negative(value: String)
        
        func toAttributedString(font: UIFont, showSign: Bool = true) -> NSAttributedString {
            let stringValue: String
            let color: UIColor
            let sign: String
            switch self {
            case .negative(value: let value):
                sign = (showSign) ? "- " : ""
                stringValue = value
                color = UIColor(red: 174.0 / 255.0, green: 53.0 / 255.0, blue: 53.0 / 255.0, alpha: 1.0)
            case .positive(value: let value):
                sign = (showSign) ? "+ " : ""
                stringValue = value
                color = UIColor(red: 31.0 / 255.0, green: 157.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
            }
            
            return NSAttributedString(string: "\(sign)\(stringValue)", attributes: [
                .font: font,
                .foregroundColor: color
                ])
        }
    }

    enum Change {
        case down(value: String)
        case up(value: String)
        
        func toAttributedString(font: UIFont) -> NSAttributedString {
            let string: String
            let color: UIColor
            switch self {
            case .down(value: let value):
                string = "↓\(value)"
                color = UIColor(red: 174.0 / 255.0, green: 53.0 / 255.0, blue: 53.0 / 255.0, alpha: 1.0)
            case .up(value: let value):
                string = "↑\(value)"
                color = UIColor(red: 31.0 / 255.0, green: 157.0 / 255.0, blue: 57.0 / 255.0, alpha: 1.0)
            }
            
            return NSAttributedString(string: string, attributes: [
                .font: font,
                .foregroundColor: color
                ])
        }
    }
    
    public static func format(balance: String, fontHeight: CGFloat, change: Change, changeFontHeight: CGFloat) -> NSAttributedString {
        let mainFont = UIFont.boldSystemFont(ofSize: fontHeight)
        let changeFont = UIFont.systemFont(ofSize: changeFontHeight)
        
        let attributedString = NSMutableAttributedString(string: "\(balance) ", attributes: [
            .font: mainFont,
            .foregroundColor: UIColor.black
            ])
        attributedString.append(change.toAttributedString(font: changeFont))
        
        return attributedString
    }
}
