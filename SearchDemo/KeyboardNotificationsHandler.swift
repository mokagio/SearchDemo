//
//  KeyboardNotificationsHandler.swift
//  SearchDemo
//
//  Created by Giovanni on 5/02/2016.
//  Copyright © 2016 Umbrella. All rights reserved.
//

import UIKit

class KeyboardNotificationsHandler {

    typealias KeyboardAnimationAction = (
        duration: NSTimeInterval,
        keyboardHeight: CGFloat,
        animationOptionCurve: UIViewAnimationOptions
        ) -> ()

    let willShowAction: KeyboardAnimationAction?
    let willHideAction: KeyboardAnimationAction?

    let notificationCenter: NSNotificationCenter

    init(
        willShowAction: KeyboardAnimationAction?,
        willHideAction: KeyboardAnimationAction?,
        notificationCenter: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        ) {
        self.willShowAction = willShowAction
        self.willHideAction = willHideAction
        self.notificationCenter = notificationCenter

        setupKeyboardNotificationObserving(self.notificationCenter)
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    func setupKeyboardNotificationObserving(notificationCenter: NSNotificationCenter) {
        notificationCenter.addObserver(
            self,
            selector: Selector("keyboardWillBeShown:"),
            name: UIKeyboardWillShowNotification,
            object: .None
        )

        notificationCenter.addObserver(
            self,
            selector: "keyboardWillBeHidden:",
            name: UIKeyboardWillHideNotification,
            object: .None
        )
    }

    // MARK: Keyboard

    @objc func keyboardWillBeShown(notification: NSNotification) {
        guard let willShowAction = willShowAction else {
            return
        }

        guard let (duration, keyboardHeight, curveOption) = keyboardAnimationInfo(fromNotification: notification) else {
            return
        }

        willShowAction(duration: duration, keyboardHeight: keyboardHeight, animationOptionCurve: curveOption)
    }

    @objc func keyboardWillBeHidden(notification: NSNotification) {
        guard let willHideAction = willHideAction else {
            return
        }

        guard let (duration, keyboardHeight, curveOption) = keyboardAnimationInfo(fromNotification: notification) else {
            return
        }

        willHideAction(duration: duration, keyboardHeight: keyboardHeight, animationOptionCurve: curveOption)
    }

    func keyboardAnimationInfo(fromNotification notification: NSNotification) -> (
        NSTimeInterval, CGFloat, UIViewAnimationOptions
        )? {
            guard let infoDictionary = notification.userInfo else {
                return .None
            }

            guard let duration = infoDictionary[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval else {
                return .None
            }

            guard let keyboardFrame = (infoDictionary[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() else {
                return .None
            }

            guard let rawValue = infoDictionary[UIKeyboardAnimationCurveUserInfoKey] as? Int else {
                return .None
            }
            guard let animationCurve = UIViewAnimationCurve(rawValue: rawValue) else {
                return .None
            }

            return (
                duration,
                keyboardFrame.size.height,
                UIViewAnimationOptions.option(withCurve: animationCurve)
            )
    }
}
