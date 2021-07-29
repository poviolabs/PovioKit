//
//  LoginValidationForm.swift
//  Demo
//
//  Created by Toni Kocjan on 29/07/2021.
//

import Foundation
import PovioKit

class LoginValidationForm: ValidationForm {
  override init() {
    super.init {
      ValidationFormInputRow(
        key: "email",
        placeholder: "Email",
        validator: { input -> DefaultValidationStatus in
          guard !input.isNilOrEmpty else { return .invalid("Required") }
          let predicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")
          switch predicate.evaluate(with: input) {
          case true:
            return .valid
          case false:
            return .invalid("Invalid email")
          }
        })
      
      ValidationFormSpacingRow(height: 27)
      
      ValidationFormInputRow(
        key: "password",
        placeholder: "Password",
        validator: nonEmptyValidator(errorMessage: "Required"),
        cellConfigurator: {
          $0.isSecure = true
          $0.autocapitalizationType = .none
        })
    }
  }
}
