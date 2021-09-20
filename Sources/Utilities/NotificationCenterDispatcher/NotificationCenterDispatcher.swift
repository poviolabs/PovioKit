//
//  NotificationCenterDispatcher.swift
//  PovioKit
//
//  Created by Borut Tomazin on 20/09/2021.
//  Copyright © 2021 Povio Labs. All rights reserved.
//

import UIKit

enum NotificationCenterDispatcher {
  typealias Json = [String: Any]
  
  /// Post a notification for given `type` and optional `data`
  static func post(_ type: NotificationType, withData data: Json? = nil) {
    var userInfo = Json()
    if let data = data {
      userInfo = data
    }
    userInfo["NotificationType"] = type.rawValue as Any?
    NotificationCenter.default.post(name: type.name, object: nil, userInfo: userInfo)
  }
  
  /// Post a notification for given `name` and optional `data`
  static func post(_ name: Notification.Name, withData data: Json? = nil) {
    var userInfo = Json()
    if let data = data {
      userInfo = data
    }
    userInfo["NotificationType"] = NotificationType(rawValue: name.rawValue) as Any?
    NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo)
  }
  
  /// Listen for notifications for given `type` on `observer` and `selector`
  static func listen(_ type: NotificationType, observer: Any, selector: Selector) {
    NotificationCenter.default.addObserver(observer, selector: selector, name: type.name, object: nil)
  }
  
  /// Listen for notifications for given `type` on `observer` with `callback`
  static func listen(_ type: NotificationType, observer: Any, _ callback: @escaping (Notification) -> Void) {
    NotificationCenter.default.addObserver(forName: type.name, object: observer, queue: nil, using: callback)
  }
  
  /// Listen for notifications for given `name` on `observer` and `selector`
  static func listen(_ name: Notification.Name, observer: Any, selector: Selector) {
    NotificationCenter.default.addObserver(observer, selector: selector, name: name, object: nil)
  }
  
  /// Listen for notifications for given `name` on `observer` with `callback`
  static func listen(_ name: Notification.Name, observer: Any, _ callback: @escaping (Notification) -> Void) {
    _ = NotificationCenter.default.addObserver(forName: name, object: observer, queue: nil, using: callback)
  }
  
  /// Remove notifications listener from observer
  static func remove(_ observer: Any, type: NotificationType?=nil) {
    switch type {
    case .some(let type):
      NotificationCenter.default.removeObserver(observer, name: type.name, object: nil)
    case .none:
      NotificationCenter.default.removeObserver(observer)
    }
  }
}

// MARK: - Notification Extension
extension Notification {
  var type: NotificationCenterDispatcher.NotificationType? {
    guard let userInfo = userInfo,
          let type = userInfo["NotificationType"] as? String,
          let notificationType = NotificationCenterDispatcher.NotificationType(rawValue: type) else {
      return nil
    }
    return notificationType
  }
}
