//
//  ErrorStateTextInputView.swift
//  Demo
//
//  Created by Nejc Vivod on 30/03/2020.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import SnapKit
import UIKit

class ErrorStateTextInputView: UIView {
  private let placeholderLabel = UILabel()
  let textField: CustomTextField
  private let errorLabel = UILabel()
  var shortPlaceholder: String? {
    didSet {
      placeholderLabel.text = shortPlaceholder
      updatePlaceholderState()
    }
  }
  private var placeholderShown = false {
    didSet {
      updatePlaceholderState()
    }
  }
  var shouldUpdateErrorStateOnEdit = true
  var placeholder: String? {
    get { textField.placeholder }
    set { textField.placeholder = newValue }
  }
  var errorColor: UIColor = .red {
    didSet {
      errorLabel.textColor = errorColor
      updateErrorState()
    }
  }

  init(textField: CustomTextField = .init(), shortPlaceholder: String? = nil) {
    self.textField = textField
    self.shortPlaceholder = shortPlaceholder
    super.init(frame: .zero)
    setupViews()
  }
  
  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func becomeFirstResponder() -> Bool {
    textField.becomeFirstResponder()
  }
}

// MARK: - Public

extension ErrorStateTextInputView {
  var errorMessage: String? {
    get { errorLabel.text }
    set {
      errorLabel.text = newValue
      updateErrorState()
    }
  }
}

// MARK: - Private

private extension ErrorStateTextInputView {
  func setupViews() {
    backgroundColor = .clear
    setupPlaceholderLabel()
    setupTextField()
    setupErrorLabel()
    setupNotifications()
  }

  func setupPlaceholderLabel() {
    addSubview(placeholderLabel)
    errorLabel.font = .boldSystemFont(ofSize: 12)
    placeholderLabel.textColor = .lightGray
    placeholderLabel.text = shortPlaceholder
    placeholderLabel.alpha = 0.0
    placeholderLabel.transform = CGAffineTransform(translationX: 0, y: 7)
    placeholderLabel.snp.makeConstraints {
      $0.top.leading.equalToSuperview()
    }
  }

  func setupTextField() {
    addSubview(textField)
    textField.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(placeholderLabel.snp.bottom).offset(8)
      $0.height.equalTo(56)
    }
  }

  func setupErrorLabel() {
    addSubview(errorLabel)
    errorLabel.font = .boldSystemFont(ofSize: 12)
    errorLabel.textColor = .red
    errorLabel.alpha = 0.0
    errorLabel.numberOfLines = 2
    errorLabel.transform = CGAffineTransform(translationX: 0, y: -7)
    errorLabel.snp.makeConstraints {
      $0.top.equalTo(textField.snp.bottom).offset(4)
      $0.height.greaterThanOrEqualTo(15)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalToSuperview()
    }
  }

  func updateErrorState() {
    guard shouldUpdateErrorStateOnEdit else { return }
    UIView.animate(withDuration: 0.2) {
      switch self.errorLabel.text?.isEmpty {
      case false:
        self.errorLabel.alpha = 1.0
        self.errorLabel.transform = .identity
        self.textField.layer.borderColor = self.errorColor.cgColor
        self.placeholderLabel.textColor = self.errorColor
      default:
        self.errorLabel.alpha = 0.0
        self.errorLabel.transform = CGAffineTransform(translationX: 0, y: -7)
        self.textField.layer.borderColor = UIColor.lightGray.cgColor
        self.placeholderLabel.textColor = .lightGray
      }
    }
  }

  func updatePlaceholderState() {
    let showPlaceholder = textField.text.isNilOrEmpty ? false : true
    UIView.animate(withDuration: 0.2) {
      switch showPlaceholder {
      case true:
        self.placeholderLabel.alpha = 1.0
        self.placeholderLabel.transform = .identity
      case false:
        self.placeholderLabel.alpha = 0.0
        self.placeholderLabel.transform = CGAffineTransform(translationX: 0, y: 7)
      }
    }
  }

  func setupNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange), name: UITextField.textDidChangeNotification, object: nil)
  }
}

// MARK: - Private selectors

private extension ErrorStateTextInputView {
  @objc func textFieldDidChange(_ sender: Notification) {
    guard (sender.object as? CustomTextField) == textField else { return }
    updatePlaceholderState()
  }
}
