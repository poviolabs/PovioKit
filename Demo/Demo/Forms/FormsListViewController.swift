//
//  FormsListViewController.swift
//  Demo
//
//  Created by Toni Kocjan on 29/07/2021.
//

import UIKit
import PovioKit

class FormsListViewController: UIViewController {
  let tableView = UITableView()
  let validationForms: [(name: String, form: ValidationForm)]
  
  init(validationForms: [(name: String, form: ValidationForm)]) {
    self.validationForms = validationForms
    super.init(nibName: nil, bundle: nil)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func loadView() {
    view = tableView
  }
}

extension FormsListViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    validationForms.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let form = validationForms[indexPath.row]
    let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
    cell.textLabel?.text = form.name
    return cell
  }
}

extension FormsListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let form = validationForms[indexPath.row].form
    let vc = FormViewController(form: form)
    navigationController?.pushViewController(vc, animated: true)
  }
}

private extension FormsListViewController {
  func setup() {
    tableView.dataSource = self
    tableView.delegate = self
  }
}
