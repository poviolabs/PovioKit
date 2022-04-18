//
//  FirstStepContentView.swift
//  Demo
//
//  Created by Marko Mijatovic on 13/04/2022.
//  Copyright © 2022 Povio Labs. All rights reserved.
//

import Foundation
import SnapKit
import PovioKit
import UIKit

class FirstStepContentView: UIView {
  private let titleLabel = UILabel()
  private let button = UIButton()
  var nextButtonCallback: (() -> Void)?
  
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
private extension FirstStepContentView {
  func setupViews() {
    backgroundColor = .init(red: 255, green: 54, blue: 83)
    layer.cornerRadius = 10
    layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    setupTitleLabel()
    setupButton()
  }
  
  func setupTitleLabel() {
    addSubview(titleLabel)
    titleLabel.font = .systemFont(ofSize: 16)
    titleLabel.textColor = .darkText
    titleLabel.textAlignment = .center
    titleLabel.text = "First step"
    titleLabel.snp.makeConstraints {
      $0.height.equalTo(40)
      $0.top.equalToSuperview().offset(10)
      $0.leading.trailing.equalToSuperview()
    }
  }
  
  func setupButton() {
    addSubview(button)
    button.setTitle("Next", for: .normal)
    button.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
    button.snp.makeConstraints {
      $0.size.equalTo(40)
      $0.top.equalTo(titleLabel.snp.bottom)
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-40)
    }
  }
  
  @objc func nextAction() {
    nextButtonCallback?()
  }
}
