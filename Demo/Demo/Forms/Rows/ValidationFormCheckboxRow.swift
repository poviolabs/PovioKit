//
//  ValidationFormCheckboxRow.swift
//  Demo
//
//  Created by Toni Kocjan on 10/09/2020.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import UIKit
import PovioKit

class ValidationFormCheckboxRow: ValidatableValidationFormRowType {
  enum Text {
    case normal(String)
    case attributed(NSAttributedString)
  }
  
  typealias Value = Bool
  typealias ValidationStatus = DefaultValidationStatus
  
  var validationStatus: ValidationStatus
  var value: Bool? // swiftlint:disable:this discouraged_optional_boolean
  let validator: Validator
  let key: String?
  var placeholder: String? { nil }
  let text: Text
  let didSelectCallback: (() -> Void)?
  
  init(
    value: Bool = false,
    text: Text,
    key: String? = nil,
    validator: @escaping Validator = { $0 == true ? .valid : .invalid("") },
    didSelectCallback: (() -> Void)? = nil
  ) {
    self.value = value
    self.text = text
    self.validator = validator
    self.key = key
    self.validationStatus = .pending
    self.didSelectCallback = didSelectCallback
  }
  
  func validationForm(_ validationForm: ValidationForm, cellForRowAt indexPath: IndexPath, in collectionView: UICollectionView) -> ValidationFormCell {
    let cell = collectionView.dequeueReusableCell(ValidationFormCheckboxCell.self, at: indexPath)
    cell.update(using: self)
    cell.didToggleCallback.delegate(to: self) { (self, value) in // swiftlint:disable:this unneeded_parentheses_in_closure_argument
      validationForm.updateRow(ValidationFormCheckboxRow.self, value: value, at: indexPath)
      self.map(cell.update)
    }
    return cell
  }
}
