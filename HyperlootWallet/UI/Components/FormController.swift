//
//  FormController.swift
//  HyperlootWallet
//
//  Created by valery_vaskabovich on 10/15/18.
//  Copyright © 2018 Hyperloot DAO. All rights reserved.
//

import Foundation
import UIKit

class FormController: NSObject {
    
    private weak var scrollView: UIScrollView?
    
    fileprivate var activeTextField: UITextField?
    private lazy var weakTextFields = WeakRefArray<UITextField>()
    
    public weak var textFieldDelegate: UITextFieldDelegate?
    
    init(scrollView: UIScrollView) {
        super.init()
        
        self.scrollView = scrollView
        configureScrollView()
    }
    
    deinit {
        unsubscribeFromNotifications()
    }
    
    public func register(textFields: [UITextField]) {
        textFields.forEach { $0.delegate = self; self.weakTextFields.add($0) }
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
            let keyboardFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
                return
        }
        
        var safeAreaBottomInset: CGFloat = 0.0
        if #available(iOS 11, *) {
            safeAreaBottomInset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0
        }
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardFrameValue.cgRectValue.height - safeAreaBottomInset, right: 0.0)
        update(contentInsets: contentInsets)
        
        scrollToActiveTextField()
    }
    
    @objc
    private func willHideKeyboard(notification: Notification) {
        update(contentInsets: UIEdgeInsets.zero)
    }
    
    private func update(contentInsets: UIEdgeInsets) {
        scrollView?.contentInset = contentInsets
        scrollView?.scrollIndicatorInsets = contentInsets
    }
}

extension FormController: UITextFieldDelegate {
    
    fileprivate func scrollToActiveTextField() {
        guard let scrollView = scrollView,
            let textField = activeTextField else {
            return
        }
        
        var frame = textField.convert(textField.bounds, to: scrollView)
        frame.origin.y -= 180.0
        scrollView.setContentOffset(CGPoint(x: 0.0, y: frame.origin.y), animated: true)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeTextField = textField
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollToActiveTextField()
    }
        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let shouldReturn = textFieldDelegate?.textFieldShouldReturn?(textField) ?? true
        return shouldReturn
    }
}
