//
//  RootContentView.swift
//  Demo
//
//  Created by Marko Mijatovic on 4/21/22.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation
import SnapKit
import PovioKitUI
import UIKit

class RootContentView: UIView {
  private let simpleDialogButton = UIButton()
  private let fadeDialogButton = UIButton()
  private let customDialogButton = UIButton()
  private let segmentedControl = UISegmentedControl(items: ["bottom", "center", "top"])
  var simpleCallback: (() -> Void)?
  var fadeCallback: (() -> Void)?
  var customCallback: (() -> Void)?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Private Methods
private extension RootContentView {
  func setupViews() {
    backgroundColor = .init(red: 78/255, green: 103/255, blue: 102/255, alpha: 1.0)
    setupSimpleDialogButton()
    setupFadeDialogButton()
    setupCustomDialogButton()
    setupSegmentedControl()
  }
  
  func setupSimpleDialogButton() {
    addSubview(simpleDialogButton)
    simpleDialogButton.setTitle("Simple animation", for: .normal)
    simpleDialogButton.addTarget(self, action: #selector(simpleButtonAction), for: .touchUpInside)
    simpleDialogButton.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalToSuperview().offset(200)
    }
  }
  
  @objc func simpleButtonAction() {
    simpleCallback?()
  }
  
  func setupFadeDialogButton() {
    addSubview(fadeDialogButton)
    fadeDialogButton.setTitle("Fade animation", for: .normal)
    fadeDialogButton.addTarget(self, action: #selector(fadeButtonAction), for: .touchUpInside)
    fadeDialogButton.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(simpleDialogButton.snp.bottom).offset(20)
    }
  }
  
  @objc func fadeButtonAction() {
    fadeCallback?()
  }
  
  func setupCustomDialogButton() {
    addSubview(customDialogButton)
    customDialogButton.setTitle("Custom animation", for: .normal)
    customDialogButton.addTarget(self, action: #selector(customButtonAction), for: .touchUpInside)
    customDialogButton.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(fadeDialogButton.snp.bottom).offset(20)
    }
  }
  
  @objc func customButtonAction() {
    customCallback?()
  }
  
  func setupSegmentedControl() {
    addSubview(segmentedControl)
    segmentedControl.backgroundColor = .white.withAlphaComponent(0.4)
    segmentedControl.addTarget(self, action: #selector(self.segmentedValueChanged(_:)), for: .valueChanged)
    resetSegmentedControl()
    segmentedControl.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(20)
      $0.top.equalTo(customDialogButton.snp.bottom).offset(20)
    }
  }
  
  @objc func segmentedValueChanged(_ sender: UISegmentedControl) {
    guard let position = sender.titleForSegment(at: sender.selectedSegmentIndex) else { return }
    UserDefaults.standard.set(position, forKey: Constants.selectedPositionUserDefaultsKey)
  }
  
  func resetSegmentedControl() {
    segmentedControl.selectedSegmentIndex = 0
    UserDefaults.standard.set("bottom", forKey: Constants.selectedPositionUserDefaultsKey)
  }
}
