//
//  ValidationFormInputCell.swift
//  Demo
//
//  Created by Toni Kocjan on 05/08/2019.
//  Copyright © 2019 Povio Labs. All rights reserved.
//

import UIKit
import PovioKit

class ValidationFormInputCell: DynamicCollectionCell, ValidationFormCell {
  private let textView = ErrorStateTextInputView()
  var isEditingEnabled = true
  var valueDidChangeCallback = Delegated<String?, Void>()
  var didSelectCallback = VoidDelegate()
  var textFormatter: ((String) -> String)?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    didSelectCallback.delegate(to: self) { _ in }
    isEditingEnabled = true
    keyboard = .default
    isSecure = false
    autocapitalizationType = .none
    returnKeyType = .next
    textFormatter = nil
  }
  
  override func becomeFirstResponder() -> Bool {
    textView.becomeFirstResponder()
  }
}

extension ValidationFormInputCell {
  func update<R: ValidatableValidationFormRowType>(
    using row: R
  ) where R.Value == String, R.ValidationStatus == DefaultValidationStatus {
    textView.textField.text = row.value
    textView.textField.placeholder = row.placeholder
    textView.shortPlaceholder = row.placeholder
    validate(status: row.validationStatus)
  }
  
  var keyboard: UIKeyboardType {
    get { textView.textField.keyboardType }
    set { textView.textField.keyboardType = newValue }
  }
  
  var returnKeyType: UIReturnKeyType {
    get { textView.textField.returnKeyType }
    set { textView.textField.returnKeyType = newValue }
  }
  
  var isSecure: Bool {
    get { textView.textField.isSecureTextEntry }
    set { textView.textField.isSecureTextEntry = newValue }
  }
  
  var autocapitalizationType: UITextAutocapitalizationType {
    get { textView.textField.autocapitalizationType }
    set { textView.textField.autocapitalizationType = newValue }
  }
}

// MARK: - Validatable
extension ValidationFormInputCell {
  func validate(status: DefaultValidationStatus) {
    switch status {
    case .valid:
      textView.errorMessage = nil
    case .invalid(let errorMessage):
      textView.errorMessage = errorMessage
    case .pending:
      textView.errorMessage = nil
    }
  }
}

private extension ValidationFormInputCell {
  func setupViews() {
    setupTextField()
  }
  
  func setupTextField() {
    contentView.addSubview(textView)
    textView.textField.delegate = self
    returnKeyType = .next
    textView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.bottom.equalToSuperview().priority(.medium)
    }
  }
}

// MARK: - UITextFieldDelegate
extension ValidationFormInputCell: UITextFieldDelegate {
  func textFieldDidEndEditing(_ textField: UITextField) {
    valueDidChangeCallback(textField.text)
  }
  
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    didSelectCallback()
    return isEditingEnabled
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    false
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    switch textFormatter {
    case let formatter?:
      let text = textField.text?.replacingString(with: string, range: range) ?? ""
      textField.text = formatter(text)
      return false
    case nil:
      return true
    }
  }
}
