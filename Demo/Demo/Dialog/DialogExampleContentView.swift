//
//  DialogExampleContentView.swift
//  Demo
//
//  Created by Marko Mijatovic on 4/21/22.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import Foundation
import SnapKit
import PovioKitUI
import UIKit

class DialogExampleContentView: DialogContentView {
  private let label = UILabel()
  private let button = UIButton()
  private let bottomLabel = UILabel()
  var doneCallback: (() -> Void)?
  
  override init() {
    super.init()
    setupViews()
  }
  
  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Private Methods
private extension DialogExampleContentView {
  func setupViews() {
    content.backgroundColor = .init(red: 247/255, green: 221/255, blue: 114/255, alpha: 1.0)
    setupLabel()
    setupButton()
    setupBottomLabel()
  }
  
  func setupLabel() {
    content.addSubview(label)
    label.text = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."
    label.font = .systemFont(ofSize: 24)
    label.textColor = .init(red: 30/255, green: 21/255, blue: 42/255, alpha: 1.0)
    label.textAlignment = .center
    label.numberOfLines = 0
    label.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalToSuperview().offset(40)
    }
  }
  
  func setupButton() {
    content.addSubview(button)
    button.setTitle("Done", for: .normal)
    button.setTitleColor(.init(red: 30/255, green: 21/255, blue: 42/255, alpha: 1.0), for: .normal)
    button.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
    button.snp.makeConstraints {
      $0.size.equalTo(140)
      $0.top.equalTo(label.snp.bottom)
      $0.centerX.equalToSuperview()
    }
  }
  
  @objc func doneAction() {
    doneCallback?()
  }
  
  func setupBottomLabel() {
    content.addSubview(bottomLabel)
    bottomLabel.text = "This is bottom label"
    bottomLabel.font = .systemFont(ofSize: 24)
    bottomLabel.textColor = .init(red: 30/255, green: 21/255, blue: 42/255, alpha: 1.0)
    bottomLabel.textAlignment = .center
    bottomLabel.snp.makeConstraints {
      $0.height.equalTo(100)
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(button.snp.bottom)
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-40)
    }
  }
}
