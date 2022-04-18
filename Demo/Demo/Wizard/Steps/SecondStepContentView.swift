//
//  SecondStepContentView.swift
//  Demo
//
//  Created by Marko Mijatovic on 13/04/2022.
//  Copyright © 2022 Povio Labs. All rights reserved.
//

import Foundation
import SnapKit
import PovioKit
import UIKit

class SecondStepContentView: UIView {
  private let titleLabel = UILabel()
  private let nextButton = UIButton()
  private let backButton = UIButton()
  var nextButtonCallback: (() -> Void)?
  var backButtonCallback: (() -> Void)?
  
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
private extension SecondStepContentView {
  func setupViews() {
    backgroundColor = .init(red: 116, green: 160, blue: 153).withAlphaComponent(0.8)
    setupTitleLabel()
    setupNextButton()
    setupBackButton()
  }
  
  func setupTitleLabel() {
    addSubview(titleLabel)
    titleLabel.font = .systemFont(ofSize: 22)
    titleLabel.textColor = .darkText
    titleLabel.textAlignment = .center
    titleLabel.text = "Second step"
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(10)
      $0.leading.trailing.equalToSuperview()
    }
  }
  
  func setupNextButton() {
    addSubview(nextButton)
    nextButton.setTitle("Next", for: .normal)
    nextButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
    nextButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(titleLabel.snp.bottom)
    }
  }
  
  @objc func nextAction() {
    nextButtonCallback?()
  }
  
  func setupBackButton() {
    addSubview(backButton)
    backButton.setTitle("Back", for: .normal)
    backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
    backButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(nextButton.snp.bottom)
      $0.bottom.equalToSuperview().offset(-100)
    }
  }
  
  @objc func backAction() {
    backButtonCallback?()
  }
}
