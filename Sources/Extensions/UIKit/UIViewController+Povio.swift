//
//  UIViewController+Povio.swift
//  PovioKit
//
//  Created by Toni Kocjan on 26/07/2020.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import UIKit

public protocol BarButtonConvertible {
  func createBarButton() -> UIBarButtonItem
}

public extension UIViewController {
  class BarButton {
    let content: Content
    let action: Selector?
    let target: Any?
    
    required public init(content: Content, action: Selector?, target: Any? = nil) {
      self.content = content
      self.action = action
      self.target = target
    }
  }
  
  class LoadingBarButton {
    let barButton: BarButton
    let animations: LoadingButton<UIButton>.Animations
    
    required public init(
      barButton: BarButton,
      animations: LoadingButton<UIButton>.Animations
    ) {
      self.barButton = barButton
      self.animations = animations
    }
  }
}

public extension UIViewController.BarButton {
  enum Content {
    case icon(UIImage)
    case title(Title)
    
    public static func icon(_ image: UIImage?) -> Content {
      .icon(image ?? UIImage())
    }
  }
}

public extension UIViewController.BarButton.Content {
  enum Title {
    case `default`(String)
    case attributed(normal: NSAttributedString, disabled: NSAttributedString?)
    
    public static func attributed(normal: NSAttributedString) -> Title {
      .attributed(normal: normal, disabled: nil)
    }
  }
}

extension UIViewController.BarButton: BarButtonConvertible {
  public func createBarButton() -> UIBarButtonItem {
    switch content {
    case .title(.default(let title)):
      let button = UIButton()
      button.setTitle(title, for: .normal)
      if let action = action {
        button.addTarget(target ?? self, action: action, for: .touchUpInside)
      }
      return .init(customView: button)
    case let .title(.attributed(normal, disabled)):
      let button = UIButton()
      button.setAttributedTitle(normal, for: .normal)
      button.setAttributedTitle(disabled, for: .disabled)
      if let action = action {
        button.addTarget(target ?? self, action: action, for: .touchUpInside)
      }
      return .init(customView: button)
    case .icon(let image):
      return .init(
        image: image.withRenderingMode(.alwaysOriginal),
        style: .plain,
        target: target ?? self,
        action: action)
    }
  }
}

extension UIViewController.LoadingBarButton: BarButtonConvertible {
  public func createBarButton() -> UIBarButtonItem {
    guard let customView = barButton.createBarButton().customView as? UIButton else {
      fatalError("Not yet implemented!")
    }
    
    let loadingView = LoadingView(
      adapt: customView,
      animations: animations)
    return .init(customView: loadingView)
  }
}


public extension UIViewController {
  @discardableResult
  func setLeftBarButton(_ convertible: BarButtonConvertible) -> UIBarButtonItem {
    let button = convertible.createBarButton()
    navigationItem.leftBarButtonItem = button
    return button
  }
  
  @discardableResult
  func setRightBarButton(_ convertible: BarButtonConvertible) -> UIBarButtonItem {
    let button = convertible.createBarButton()
    navigationItem.rightBarButtonItem = button
    return button
  }
  
  @discardableResult
  func setLeftBarButtons(_ convertibles: [BarButtonConvertible]) -> [UIBarButtonItem] {
    let buttons = convertibles.map { $0.createBarButton() }
    navigationItem.leftBarButtonItems = buttons
    return buttons
  }
  
  @discardableResult
  func setRightBarButtons(_ convertibles: [BarButtonConvertible]) -> [UIBarButtonItem] {
    let buttons = convertibles.map { $0.createBarButton() }
    navigationItem.rightBarButtonItems = buttons
    return buttons
  }
}
