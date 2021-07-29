//
//  SignUpValidationForm.swift
//  Demo
//
//  Created by Toni Kocjan on 29/07/2021.
//

import Foundation
import PovioKit

func passwordMultipleRuleValidator() -> (String?) -> [ValidationStatusTextInputView.ValidationStatusView.Rule] {
  { password in
    [
      .init(state: password!.count >= 8 ? .valid : .invalid, text: "Must be at least 8 characters long"),
      .init(state: password!.contains(where: { $0.isLowercase }) ? .valid : .invalid, text: "Must contain at least one lowercase letter"),
      .init(state: password!.contains(where: { $0.isUppercase }) ? .valid : .invalid, text: "Must contain at least one uppercase letter")
    ]
  }
}

class SignUpValidationForm: ValidationForm {
  override init() {
    super.init {
      ValidationFormInputRow(
        key: "name",
        placeholder: "Name",
        validator: nonEmptyValidator(errorMessage: "Required"))
      ValidationFormSpacingRow(height: 17)
      ValidationFormInputRow( // swiftlint:disable:this trailing_closure
        key: "email",
        placeholder: "Email",
        validator: nonEmptyValidator(errorMessage: "Required"),
        cellConfigurator: {
          $0.keyboard = .emailAddress
          $0.autocapitalizationType = .none
        })
      ValidationFormSpacingRow(height: 27)
      ValidationFormMultipleRuleRow(
        value: "",
        key: "password",
        placeholder: "Password",
        validator: passwordMultipleRuleValidator())
      ValidationFormSpacingRow(height: 38)
    }
    appendRow(
      ValidationFormCheckboxRow( // swiftlint:disable:this trailing_closure
        text: .normal("Terms and Conditions"),
        didSelectCallback: {
          /// Do something
          print("Terms and conditions pressed")
        }))
  }
}
