//
//  UIResponder+PovioKit.swift
//  PovioKit
//
//  Created by Borut Tomažin on 13/11/2020.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

#if os(iOS)
import UIKit

public extension UIResponder {
  /// Finds and returns first `UIResponder` up in the chain of given `type`.
  ///
  /// If you want to quickly find certain view type in the view hierachy:
  ///
  /// ## Example
  /// ```swift
  /// MainViewController
  /// --> ContentView
  ///   --> ButtonsContainerView
  ///
  /// let firstResponder = buttonsContainerView.firstResponder(ofType: MainViewController)
  /// ```
  func firstResponder<T: AnyObject>(ofType type: T.Type) -> T? {
    var current: UIResponder? = self
    while current != nil {
      if let target = current as? T {
        return target
      }
      current = current?.next
    }
    return nil
  }
}
#endif
