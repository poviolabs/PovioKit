//
//  RootViewController.swift
//  Demo
//
//  Created by Marko Mijatovic on 4/21/22.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import UIKit
import PovioKitUI

class RootViewController: UIViewController {
  lazy var contentView = RootContentView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
  }
  
  override func loadView() {
    view = contentView
  }
}

// MARK: - Private Methods
private extension RootViewController {
  func setupViews() {
    contentView.simpleCallback = {
      let dialog = DialogExampleViewController(contentView: DialogExampleContentView(), position: self.getPosition(), animation: .none)
      self.navigationController?.present(dialog, animated: true)
    }
    contentView.fadeCallback = {
      let dialog = DialogExampleViewController(contentView: DialogExampleContentView(), position: self.getPosition(), animation: .fade)
      self.navigationController?.present(dialog, animated: true)
    }
    contentView.flipCallback = {
      let dialog = DialogExampleViewController(contentView: DialogExampleContentView(), position: self.getPosition(), animation: .flip)
      self.navigationController?.present(dialog, animated: true)
    }
    contentView.pushCallback = {
      let dialog = DialogExampleViewController(contentView: DialogExampleContentView(), position: self.getPosition(), animation: .pushPop)
      self.navigationController?.present(dialog, animated: true)
    }
    contentView.customCallback = {
      let dialog = DialogExampleViewController(contentView: DialogExampleContentView(), position: self.getPosition(), animation: .custom(CustomAnimation()))
      self.navigationController?.present(dialog, animated: true)
    }
  }
  
  func getPosition() -> DialogPosition {
    let position = UserDefaults.standard.string(forKey: Constants.selectedPositionUserDefaultsKey) ?? "bottom"
    switch position.lowercased() {
    case "bottom": return .bottom
    case "center": return .center
    case "top": return .top
    default: return .bottom
    }
  }
}

enum Constants {
  static let selectedPositionUserDefaultsKey = "selectedPositionUserDefaultsKey"
}
