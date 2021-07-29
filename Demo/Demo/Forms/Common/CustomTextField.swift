//
//  CustomTextField.swift
//  Demo
//
//  Created by Nejc Vivod on 30/03/2020.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import PovioKit
import UIKit

class CustomTextField: UITextField {
  private var visibilityButton: UIButton?
  private var padding: UIEdgeInsets = .init(horizontal: 20) { didSet { setNeedsLayout() } }

  override var text: String? {
    didSet {
      NotificationCenter.default.post(name: UITextField.textDidChangeNotification, object: nil)
    }
  }

  override var placeholder: String? {
    didSet {
      stylePlaceholder()
    }
  }

  init() {
    super.init(frame: .zero)
    setupViews()
  }
  
  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override open func textRect(forBounds bounds: CGRect) -> CGRect {
    bounds.inset(by: padding).inset(by: .init(top: 0, left: 0, bottom: 0, right: 30))
  }

  override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
    bounds.inset(by: padding).inset(by: .init(top: 0, left: 0, bottom: 0, right: 30))
  }

  override open func editingRect(forBounds bounds: CGRect) -> CGRect {
    bounds.inset(by: padding).inset(by: .init(top: 0, left: 0, bottom: 0, right: 30))
  }
  
  override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
    .init(x: bounds.width - (rightView === visibilityButton ? 0 : 30) - padding.right, y: bounds.height * 0.5 - 15, width: 30, height: 30)
  }
  
  static var password: CustomTextField {
    let textField = CustomTextField()
    textField.placeholder = "placeholder_password".localized()
    textField.autocapitalizationType = .none
    textField.isSecureTextEntry = true
    textField.padding.right = 50
    return textField
  }
}

// MARK: - Private methods

private extension CustomTextField {
  func setupViews() {
    backgroundColor = .clear
    font = .systemFont(ofSize: 15)
    textColor = .black
    layer.borderWidth = 1.0
    layer.cornerRadius = 15.0
    layer.borderColor = UIColor.lightGray.cgColor
    rightViewMode = .whileEditing
  }

  func stylePlaceholder() {
    attributedPlaceholder = AttributedStringBuilder().apply(on: placeholder ?? "") {
      $0.setTextColor(.lightGray)
    }
  }
}

// MARK: - Actions

private extension CustomTextField {
  @objc func didTapClearTextButton() {
    text = nil
    _ = delegate?.textField?(self, shouldChangeCharactersIn: NSRange(location: 0, length: text?.count ?? 0), replacementString: "")
    NotificationCenter.default.post(name: UITextField.textDidChangeNotification, object: self)
  }
}
