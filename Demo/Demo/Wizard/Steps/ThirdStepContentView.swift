//
//  ThirdStepContentView.swift
//  Demo
//
//  Created by Marko Mijatovic on 13/04/2022.
//  Copyright © 2022 Povio Labs. All rights reserved.
//

import Foundation
import SnapKit
import PovioKit
import UIKit

class ThirdStepContentView: UIView {
  private let titleLabel = UILabel()
  private let button = UIButton()
  private let imageView = UIImageView()
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
private extension ThirdStepContentView {
  func setupViews() {
    backgroundColor = .init(red: 61, green: 45, blue: 97).withAlphaComponent(0.9)
    layer.cornerRadius = 10
    layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    setupTitleLabel()
    setupButton()
    setupImageView()
  }
  
  func setupTitleLabel() {
    addSubview(titleLabel)
    titleLabel.font = .systemFont(ofSize: 18)
    titleLabel.textColor = .darkText
    titleLabel.textAlignment = .center
    titleLabel.text = "Third step"
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(10)
      $0.leading.trailing.equalToSuperview()
    }
  }
  
  func setupButton() {
    addSubview(button)
    button.setTitle("Back", for: .normal)
    button.addTarget(self, action: #selector(backAction), for: .touchUpInside)
    button.snp.makeConstraints {
      $0.size.equalTo(60)
      $0.centerX.equalToSuperview()
      $0.top.equalTo(titleLabel.snp.bottom)
    }
  }
  
  @objc func backAction() {
    backButtonCallback?()
  }
  
  func setupImageView() {
    addSubview(imageView)
    imageView.image = UIImage(systemName: "books.vertical.fill")?.tinted(with: .white)
    imageView.contentMode = .scaleAspectFit
    imageView.snp.makeConstraints {
      $0.size.equalTo(80)
      $0.centerX.equalToSuperview()
      $0.top.equalTo(button.snp.bottom).offset(10)
      $0.bottom.equalToSuperview().offset(-80)
    }
  }
}
