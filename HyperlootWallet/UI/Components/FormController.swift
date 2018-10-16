//
//  FormController.swift
//  HyperlootWallet
//
//  Created by valery_vaskabovich on 10/15/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import UIKit

class FormController {
    
    private weak var scrollView: UIScrollView?
    
    init(scrollView: UIScrollView) {
        self.scrollView = scrollView
        
        configureScrollView()
    }
    
    deinit {
        unsubscribeFromNotifications()
    }
    
    private func configureScrollView() {
        scrollView?.keyboardDismissMode = .interactive
    }
    
    public func willShowForm() {
        subscribeToNotifications()
    }
    
    public func willHideForm() {
        unsubscribeFromNotifications()
    }
    
    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboard(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    private func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc
    private func willShowKeyboard(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let keyboardFrameValue = userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue else {
                return
        }
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardFrameValue.cgRectValue.height, right: 0.0)
        scrollView?.contentInset = contentInsets
        scrollView?.scrollIndicatorInsets = contentInsets
    }
    
    @objc
    private func willHideKeyboard(notification: Notification) {
        scrollView?.contentInset = UIEdgeInsets.zero
        scrollView?.scrollIndicatorInsets = UIEdgeInsets.zero
    }
}
