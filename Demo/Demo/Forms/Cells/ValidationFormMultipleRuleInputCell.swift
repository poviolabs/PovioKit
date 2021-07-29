//
//  ValidationFormMultipleRuleInputCell.swift
//  Demo
//
//  Created by Toni Kocjan on 02/09/2020.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import UIKit
import PovioKit

class ValidationFormMultipleRuleInputCell: DynamicCollectionCell, ValidationFormCell {
  private let textView = ValidationStatusTextInputView(textField: .password)
  var isEditingEnabled = true
  var valueDidChangeCallback = Delegated<String?, Void>()
  var didSelectCallback = VoidDelegate()
  
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
    isSecure = true
    autocapitalizationType = .none
    returnKeyType = .next
  }
  
  override func becomeFirstResponder() -> Bool {
    textView.textField.becomeFirstResponder()
    return true
  }
}

extension ValidationFormMultipleRuleInputCell {
  func update<R: ValidatableValidationFormRowType>(
    using row: R
  ) where R.Value == String, R.ValidationStatus == ValidationStatus {
    textView.textField.placeholder = row.placeholder
    textView.textField.text = row.value
    textView.updateValidationStatus(using: row.validationStatus.statuses)
    if row.validationStatus.state == .pending {
      textView.textField.layer.borderColor = UIColor.gray.cgColor
    }
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

private extension ValidationFormMultipleRuleInputCell {
  func setupViews() {
    isSecure = true
    setupTextField()
  }
  
  func setupTextField() {
    contentView.addSubview(textView)
    textView.textField.delegate = self
    returnKeyType = .next
    autocapitalizationType = .none
    textView.snp.makeConstraints {
      $0.top.bottom.equalToSuperview().priority(.medium)
      $0.leading.trailing.equalToSuperview().priority(.required)
    }
  }
}

// MARK: - UITextFieldDelegate
extension ValidationFormMultipleRuleInputCell: UITextFieldDelegate {
  func textFieldDidEndEditing(_ textField: UITextField) {
  }
  
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    didSelectCallback()
    return isEditingEnabled
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    true
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let text = textField.text?.replacingString(with: string, range: range)
    valueDidChangeCallback(text)
    return false
  }
}

// MARK: - ValidationStatus
extension ValidationFormMultipleRuleInputCell {
  struct ValidationStatus: ValidationStatusConforming {
    fileprivate let statuses: [ValidationStatusTextInputView.ValidationStatusView.Rule] // swiftlint:disable:this strict_fileprivate
    fileprivate let state: State // swiftlint:disable:this strict_fileprivate
    
    static func valid(_ statuses: [ValidationStatusTextInputView.ValidationStatusView.Rule]) -> ValidationFormMultipleRuleInputCell.ValidationStatus {
      precondition(!statuses.isEmpty, "Must contain at least one status!")
      return .init(statuses: statuses, state: .valid)
    }
    
    static func invalid(_ statuses: [ValidationStatusTextInputView.ValidationStatusView.Rule]) -> ValidationFormMultipleRuleInputCell.ValidationStatus {
      precondition(!statuses.isEmpty, "Must contain at least one status!")
      return .init(statuses: statuses, state: .invalid)
    }
    
    static func pending(_ statuses: [ValidationStatusTextInputView.ValidationStatusView.Rule]) -> ValidationFormMultipleRuleInputCell.ValidationStatus {
      precondition(!statuses.isEmpty, "Must contain at least one status!")
      return .init(statuses: statuses, state: .pending)
    }
    
    var isValid: Bool { state == .valid }
  }

  enum State {
    case valid, invalid, pending
  }
}
