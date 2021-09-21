//
//  NotificationCenterDispatcher+Models.swift
//  PovioKit
//
//  Created by Borut Tomazin on 20/09/2021.
//  Copyright © 2021 Povio Labs. All rights reserved.
//

import UIKit

public extension NotificationCenterDispatcher {
  enum NotificationType {
    case onAppStart
    case onAppResume
    case onAppSleep
    case keyboardWillShow
    case keyboardDidShow
    case keyboardWillHide
    case keyboardDidHide
    case custom(name: Notification.Name)
    
    var rawValue: String {
      name.rawValue
    }
    
    var name: Notification.Name {
      switch self {
      case .onAppStart:
        return UIApplication.didFinishLaunchingNotification
      case .onAppResume:
        return UIApplication.willEnterForegroundNotification
      case .onAppSleep:
        return UIApplication.willResignActiveNotification
      case .keyboardWillShow:
        return UIResponder.keyboardWillShowNotification
      case .keyboardDidShow:
        return UIResponder.keyboardDidShowNotification
      case .keyboardWillHide:
        return UIResponder.keyboardWillHideNotification
      case .keyboardDidHide:
        return UIResponder.keyboardDidHideNotification
      case .custom(let name):
        return name
      }
    }
    
    init?(rawValue: String) {
      switch rawValue {
      case Self.onAppStart.rawValue:
        self = .onAppStart
      case Self.onAppResume.rawValue:
        self = .onAppResume
      case Self.onAppSleep.rawValue:
        self = .onAppSleep
      case Self.keyboardWillShow.rawValue:
        self = .keyboardWillShow
      case Self.keyboardDidShow.rawValue:
        self = .keyboardDidShow
      case Self.keyboardWillHide.rawValue:
        self = .keyboardWillHide
      case Self.keyboardDidHide.rawValue:
        self = .keyboardDidHide
      case _:
        self = .custom(name: Notification.Name(rawValue))
      }
    }
  }
}
