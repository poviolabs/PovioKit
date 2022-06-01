//
//  UIResponderTests.swift
//  PovioKit_Tests
//
//  Created by Gentian Barileva on 01/06/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import XCTest
import PovioKit

class UIResponderTests: XCTestCase {
  func test_firstResponder_returnsCorrectType() {
    let sut = MainViewController()
    sut.loadView()
    
    let firstResponder = sut.buttonsContainerView.firstResponder(ofType: type(of: sut))
    
    XCTAssertNotNil(firstResponder)
    XCTAssertEqual(sut, firstResponder)
  }
}

// MARK: - Helpers
private class MainViewController: UIViewController {
  let contentView = ContentView()
  let buttonsContainerView = ButtonsContainerView()
  
  override func loadView() {
    view = contentView
    view.addSubview(buttonsContainerView)
  }
}

private class ContentView: UIView { }
private class ButtonsContainerView: UIView { }
