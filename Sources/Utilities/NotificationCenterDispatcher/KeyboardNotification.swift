//
//  KeyboardNotification.swift
//  PovioKit
//
//  Created by Borut Tomazin on 20/09/2021.
//  Copyright © 2021 Povio Labs. All rights reserved.
//

import UIKit

public struct KeyboardNotification {
  private let notification: Notification
  let keyboardSize: CGSize
  let keyboardFrameBegin: CGRect
  let keyboardFrameEnd: CGRect
  let animationDuration: TimeInterval
  let animationCurve: UIView.AnimationOptions
  
  public init?(notification: Notification) {
    guard let userInfo = notification.userInfo else { return nil }
    
    self.notification = notification
    keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size ?? .zero
    keyboardFrameBegin = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
    keyboardFrameEnd = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
    animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
    if let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
      animationCurve = UIView.AnimationOptions(rawValue: curve << 16)
    } else {
      animationCurve = UIView.AnimationOptions()
    }
  }
}
