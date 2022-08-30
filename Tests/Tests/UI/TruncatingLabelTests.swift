//
//  TruncatingLabelTests.swift
//  
//
//  Created by Toni K. Turk on 29/08/2022.
//

import PovioKitUI
import XCTest
import SnapshotTesting
import UIKit
import SnapKit

class TruncatingLabelTests: XCTestCase {
  static var rng = RNG(seed: 42349023)
  var record = false // set to true if you want to re-record screenshots
  
  let randomStrings: [(String, String)] = (0..<400).map { _ in
    let primary = "a" + (0..<Int.random(in: 30...100, using: &rng)).map { _ in Int.random(in: 0...10, using: &rng) == 0 ? " " : "a" }.joined(separator: "")
    let secondary = (0..<Int.random(in: 5...20, using: &rng)).map { _ in "b" }.joined(separator: "")
    return (primary, secondary)
  }
  
  func testTruncatingLabelInAListGravityLeft1412() {
    for i in 0..<20 {
      let startIndex = i * 20
      let endIndex = i * 20 + 20
      let vc = ViewController2(
        dataSource: Array(randomStrings[startIndex..<endIndex]),
        primaryFont: .systemFont(ofSize: 14),
        secondaryFont: .systemFont(ofSize: 12),
        gravitiy: .left
      )
      assertSnapshot(matching: vc, as: .image, record: record)
    }
  }
  
  func testTruncatingLabelInAListGravityLeft2014() {
    for i in 0..<20 {
      let startIndex = i * 20
      let endIndex = i * 20 + 20
      let vc = ViewController2(
        dataSource: Array(randomStrings[startIndex..<endIndex]),
        primaryFont: .systemFont(ofSize: 20),
        secondaryFont: .systemFont(ofSize: 14),
        gravitiy: .left
      )
      assertSnapshot(matching: vc, as: .image, record: record)
    }
  }
  
  func testTruncatingLabelInAListGravityLeft3024() {
    for i in 0..<20 {
      let startIndex = i * 20
      let endIndex = i * 20 + 20
      let vc = ViewController2(
        dataSource: Array(randomStrings[startIndex..<endIndex]),
        primaryFont: .systemFont(ofSize: 30),
        secondaryFont: .systemFont(ofSize: 24),
        gravitiy: .left
      )
      assertSnapshot(matching: vc, as: .image, record: record)
    }
  }
  
  func testTruncatingLabelInAListGravityRight1412() {
    for i in 0..<20 {
      let startIndex = i * 20
      let endIndex = i * 20 + 20
      let vc = ViewController2(
        dataSource: Array(randomStrings[startIndex..<endIndex]),
        primaryFont: .systemFont(ofSize: 14),
        secondaryFont: .systemFont(ofSize: 12),
        gravitiy: .right
      )
      assertSnapshot(matching: vc, as: .image, record: record)
    }
  }
  
  func testTruncatingLabelInAListGravityRight2014() {
    for i in 0..<20 {
      let startIndex = i * 20
      let endIndex = i * 20 + 20
      let vc = ViewController2(
        dataSource: Array(randomStrings[startIndex..<endIndex]),
        primaryFont: .systemFont(ofSize: 20),
        secondaryFont: .systemFont(ofSize: 14),
        gravitiy: .right
      )
      assertSnapshot(matching: vc, as: .image, record: record)
    }
  }
  
  func testTruncatingLabelInAListGravityRight3024() {
    for i in 0..<20 {
      let startIndex = i * 20
      let endIndex = i * 20 + 20
      let vc = ViewController2(
        dataSource: Array(randomStrings[startIndex..<endIndex]),
        primaryFont: .systemFont(ofSize: 30),
        secondaryFont: .systemFont(ofSize: 24),
        gravitiy: .right
      )
      assertSnapshot(matching: vc, as: .image, record: record)
    }
  }
}

class ViewController2: UIViewController {
  let tableView = UITableView()
  let dataSource: [(String, String)]
  let primaryFont: UIFont
  let secondaryFont: UIFont
  let gravity: TruncatingLabel.Gravity
  
  init(dataSource: [(String, String)], primaryFont: UIFont, secondaryFont: UIFont, gravitiy: TruncatingLabel.Gravity) {
    self.primaryFont = primaryFont
    self.secondaryFont = secondaryFont
    self.dataSource = dataSource
    self.gravity = gravitiy
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(tableView)
    tableView.dataSource = self
    tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
    tableView.register(Cell.self)
    tableView.reloadData()
    tableView.delegate = self
  }
}

struct RNG: RandomNumberGenerator {
  init(seed: Int) {
    srand48(seed)
  }
  
  let range: ClosedRange<Double> = Double(UInt64.min) ... Double(UInt64.max)
  
  func next() -> UInt64 {
    let rnd = UInt64(range.lowerBound + (range.upperBound - range.lowerBound) * drand48())
    return rnd
  }
}

extension ViewController2: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    dataSource.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(Cell.self, at: indexPath)
    cell.label.primaryFont = primaryFont
    cell.label.secondaryFont = secondaryFont
    cell.label.primaryText = dataSource[indexPath.row].0
    cell.label.secondaryText = dataSource[indexPath.row].1
    cell.label.gravity = gravity
    cell.label.setNeedsDisplay()
    return cell
  }
}

extension ViewController2: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
    (cell as! Cell).label.setNeedsDisplay()
  }
}

class Cell: UITableViewCell {
  let label = TruncatingLabel()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(label)
    label.snp.makeConstraints {
      $0.top.bottom.equalToSuperview().inset(3)
      $0.leading.trailing.equalToSuperview().inset(20)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

