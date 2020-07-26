//
//  UIViewController+Povio.swift
//  PovioKit
//
//  Created by Toni Kocjan on 26/07/2020.
//

import UIKit

public extension UIViewController {
  struct BarButton {
    let image: UIImage?
    let title: Title?
    let action: Selector
  }
  
  func setLeftBarButton(_ barButton: BarButton) {
    navigationItem.leftBarButtonItem = createButton(using: barButton)
  }
  
  func setRightBarButton(_ barButton: BarButton) {
    navigationItem.rightBarButtonItem = createButton(using: barButton)
  }
}

public extension UIViewController.BarButton {
  enum Title {
    case text(String)
    case attributed(normal: NSAttributedString, disabled: NSAttributedString?)
  }
}

private extension UIViewController {
  func createButton(using barButton: BarButton) -> UIBarButtonItem {
    let button = UIButton()
    button.setImage(barButton.image, for: .normal)
    button.addTarget(self, action: barButton.action, for: .touchUpInside)
    
    switch barButton.title {
    case .text(let string):
      button.setTitle(string, for: .normal)
      return UIBarButtonItem(customView: button)
    case let .attributed(normal, disabled):
      button.setAttributedTitle(normal, for: .normal)
      button.setAttributedTitle(disabled, for: .disabled)
      return UIBarButtonItem(customView: button)
    case .none:
      return UIBarButtonItem(image: barButton.image,
                             style: .plain,
                             target: self,
                             action: barButton.action)
    }
  }
}
