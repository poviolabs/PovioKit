//
//  KeyboardNotification.swift
//  PovioKit
//
//  Created by Borut Tomazin on 20/09/2021.
//  Copyright © 2021 Povio Labs. All rights reserved.
//

import UIKit

struct KeyboardNotification {
  private let notification: Notification
  private let userInfo: NSDictionary
  var keyboardSize: CGSize {
    if let rect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
      return rect.cgRectValue.size
    }
    return .zero
  }
  var animationDuration: TimeInterval {
    userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
  }
  var animationCurve: UIView.AnimationOptions {
    if let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
      return UIView.AnimationOptions(rawValue: curve << 16)
    }
    return UIView.AnimationOptions()
  }
  var keyboardFrameBegin: CGRect {
    (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
  }
  var keyboardFrameEnd: CGRect {
    (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
  }
  
  init(notification: Notification) {
    self.notification = notification
    if let userInfo = (notification as NSNotification).userInfo {
      self.userInfo = userInfo as NSDictionary
    } else {
      self.userInfo = NSDictionary()
    }
  }
}
