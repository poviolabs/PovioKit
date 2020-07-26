//
//  UIViewController+Povio.swift
//  PovioKit
//
//  Created by Toni Kocjan on 26/07/2020.
//

import UIKit

public extension UIViewController {
  class BarButton {
    let content: Content
    let action: Selector
    
    init(content: Content, action: Selector) {
      self.content = content
      self.action = action
    }
  }
  
  enum Content {
    case icon(UIImage)
    case title(Title)
    
    static func icon(_ image: UIImage?) -> Content {
      .icon(image ?? UIImage())
    }
  }
  
  enum Title {
    case `default`(String)
    case attributed(normal: NSAttributedString, disabled: NSAttributedString?)
    
    static func attributed(normal: NSAttributedString) -> Title {
      .attributed(normal: normal, disabled: nil)
    }
  }
}

extension UIViewController {
  @discardableResult
  func setLeftBarButton(_ barButton: BarButton) -> UIBarButtonItem {
    let button = createButton(using: barButton)
    navigationItem.leftBarButtonItem = button
    return button
  }
  
  @discardableResult
  func setRightBarButton(_ barButton: BarButton) -> UIBarButtonItem {
    let button = createButton(using: barButton)
    navigationItem.rightBarButtonItem = button
    return button
  }
}

private extension UIViewController {
  func createButton(using barButton: BarButton) -> UIBarButtonItem {
    switch barButton.content {
    case .title(.default(let title)):
      let button = UIButton()
      button.addTarget(self, action: barButton.action, for: .touchUpInside)
      button.setTitle(title, for: .normal)
      return UIBarButtonItem(customView: button)
    case let .title(.attributed(normal, disabled)):
      let button = UIButton()
      button.addTarget(self, action: barButton.action, for: .touchUpInside)
      button.setAttributedTitle(normal, for: .normal)
      button.setAttributedTitle(disabled, for: .disabled)
      return UIBarButtonItem(customView: button)
    case .icon(let image):
      return UIBarButtonItem(image: image.withRenderingMode(.alwaysOriginal),
                             style: .plain,
                             target: self,
                             action: barButton.action)
    }
  }
}
