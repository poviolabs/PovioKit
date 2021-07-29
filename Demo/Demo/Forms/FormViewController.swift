//
//  FormViewController.swift
//  Demo
//
//  Created by Toni Kocjan on 29/07/2021.
//

import UIKit
import PovioKit

class FormViewController<F: ValidationForm>: UIViewController {
  let formView: ValidationFormView<F>
  
  init(form: F) {
    formView = .init(validationForm: form)
    super.init(nibName: nil, bundle: nil)
    setupViews()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupViews() {
    view.backgroundColor = .white
    view.addSubview(formView)
    formView.backgroundColor = .white
    formView.snp.makeConstraints { $0.edges.equalToSuperview() }
    formView.contentInset = .init(horizontal: 20)
    
    formView.register(ValidationFormInputCell.self)
    formView.register(ValidationFormSpacingCell.self)
    formView.register(ValidationFormMultipleRuleInputCell.self)
    formView.register(ValidationFormCheckboxCell.self)
    
    navigationItem.rightBarButtonItem = .init(
      barButtonSystemItem: .done,
      target: self, action: #selector(didTapActionItem))
  }
  
  @objc func didTapActionItem() {
    formView.validate()
  }
}
