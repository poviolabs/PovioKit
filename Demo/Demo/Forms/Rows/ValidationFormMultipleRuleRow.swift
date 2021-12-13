//
//  ValidationFormPasswordRow.swift
//  Demo
//
//  Created by Toni Kocjan on 31/08/2020.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import UIKit
import PovioKit

class ValidationFormMultipleRuleRow: ValidatableValidationFormRowType {
  typealias Value = String
  typealias ValidationStatus = ValidationFormMultipleRuleInputCell.ValidationStatus
  
  var validationStatus: ValidationStatus
  var value: String?
  let validator: Validator
  let key: String?
  let placeholder: String?
  
  init(
    value: String? = nil,
    key: String?,
    placeholder: String?,
    validator: @escaping (String?) -> [ValidationStatusTextInputView.ValidationStatusView.Rule]
  ) {
    self.value = value
    self.key = key
    self.placeholder = placeholder
    self.validator = {
      let statuses = validator($0)
      switch statuses.areAllValid {
      case true:
        return .valid(statuses)
      case false:
        return .invalid(statuses)
      }
    }
    self.validationStatus = .pending(validator(""))
  }
  
  func validationForm(_ validationForm: ValidationForm, cellForRowAt indexPath: IndexPath, in collectionView: UICollectionView) -> ValidationFormCell {
    let cell = collectionView.dequeueReusableCell(ValidationFormMultipleRuleInputCell.self, at: indexPath)
    cell.update(using: self)
    cell.valueDidChangeCallback.delegate(to: self) { (self, value) in // swiftlint:disable:this unneeded_parentheses_in_closure_argument
      validationForm.updateRow(ValidationFormMultipleRuleRow.self, value: value, at: indexPath)
      self.map(cell.update) // update so that validation status is immediately visible
    }
    return cell
  }
}

fileprivate extension Collection where Element == ValidationStatusTextInputView.ValidationStatusView.Rule {
  var areAllValid: Bool {
    allSatisfy { $0.state == .valid }
  }
}
