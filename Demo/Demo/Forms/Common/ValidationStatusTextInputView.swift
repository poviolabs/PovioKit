//
//  ValidationStatusTextInputView.swift
//  Demo
//
//  Created by Toni Kocjan on 30/07/2020.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import UIKit

class ValidationStatusTextInputView: UIView {
  private let textInputView: ErrorStateTextInputView
  private let stackView = UIStackView()
  
  init(textField: CustomTextField = .init(), shortPlaceholder: String? = nil) {
    self.textInputView = .init(textField: textField, shortPlaceholder: shortPlaceholder)
    super.init(frame: .zero)
    setupViews()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override var intrinsicContentSize: CGSize {
    .init(
      width: frame.width,
      height: textInputView.frame.height + 20 + stackView.frame.height
    )
  }
}

// MARK: - Public

extension ValidationStatusTextInputView {
  func updateValidationStatus(using viewModels: [ValidationStatusView.Rule]) {
    if stackView.arrangedSubviews.count < viewModels.count {
      let difference = viewModels.count - stackView.arrangedSubviews.count
      for _ in 0..<difference {
        stackView.addArrangedSubview(ValidationStatusView())
      }
      invalidateIntrinsicContentSize()
    }
    
    for (viewModel, view) in zip(viewModels, stackView.arrangedSubviews) {
      guard let statusView = view as? ValidationStatusView else { continue }
      statusView.update(using: viewModel)
    }
    
    let isValid = viewModels.allSatisfy { $0.state == .valid }
    textField.layer.borderColor = isValid ? UIColor.lightGray.cgColor : UIColor.red.cgColor
  }
  
  var textField: UITextField {
    textInputView.textField
  }
}

// MARK: - Private

private extension ValidationStatusTextInputView {
  func setupViews() {
    setupTextInputView()
    setupStackView()
  }
  
  func setupTextInputView() {
    addSubview(textInputView)
    textInputView.snp.makeConstraints {
      $0.leading.top.trailing.equalToSuperview()
    }
  }
  
  func setupStackView() {
    addSubview(stackView)
    stackView.axis = .vertical
    stackView.distribution = .fillEqually
    stackView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(15)
      $0.bottom.equalToSuperview()
      $0.top.equalTo(textInputView.snp.bottom).offset(7)
    }
  }
}

// MARK: - ValidationStatusView

extension ValidationStatusTextInputView {
  class ValidationStatusView: UIView {
    let icon = UIImageView()
    let label = UILabel()
    
    init() {
      super.init(frame: .zero)
      setupViews()
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }
}

extension ValidationStatusTextInputView.ValidationStatusView {
  struct Rule {
    let state: State
    let text: String
  }
  
  enum State {
    case valid
    case invalid
  }
  
  func update(using viewModel: Rule) {
    label.text = viewModel.text
    switch viewModel.state {
    case .invalid:
      label.textColor = UIColor.black
      icon.image = UIImage(named: "iconDotGray")
    case .valid:
      label.textColor = UIColor.green
      icon.image = UIImage(named: "iconsCheckmarkBlack")
    }
  }
}

private extension ValidationStatusTextInputView.ValidationStatusView {
  func setupViews() {
    setupIcon()
    setupLabel()
  }
  
  func setupIcon() {
    addSubview(icon)
    icon.snp.makeConstraints {
      $0.leading.top.bottom.equalToSuperview()
      $0.height.equalTo(30)
    }
  }
  
  func setupLabel() {
    addSubview(label)
    label.font = .systemFont(ofSize: 15)
    label.snp.makeConstraints {
      $0.leading.equalTo(icon.snp.trailing).offset(7)
      $0.centerY.equalToSuperview()
    }
  }
}
