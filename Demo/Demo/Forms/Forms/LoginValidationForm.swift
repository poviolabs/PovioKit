//
//  LoginValidationForm.swift
//  Demo
//
//  Created by Toni Kocjan on 29/07/2021.
//

import Foundation
import PovioKit

func passwordValidator(_ value: String?) -> DefaultValidationStatus {
  guard !value.isNilOrEmpty else {
    return .invalid("Must not be empty")
  }
  let predicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")
  switch predicate.evaluate(with: value) {
  case true:
    return .valid
  case false:
    return .invalid("Invalid email")
  }
}

class LoginValidationForm: ValidationForm {
  override init() {
    super.init {
      ValidationFormInputRow(
        key: "email",
        placeholder: "Email",
        validator: passwordValidator)
      
      ValidationFormSpacingRow(height: 27)
      
      ValidationFormInputRow(
        key: "password",
        placeholder: "Password",
        validator: nonEmptyValidator(errorMessage: "Must not be empty"),
        cellConfigurator: {
          $0.isSecure = true
          $0.autocapitalizationType = .none
        })
    }
  }
}
