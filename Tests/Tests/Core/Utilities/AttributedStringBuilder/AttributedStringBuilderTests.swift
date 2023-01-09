//
//  AttributedStringBuilderTests.swift
//  PovioKit_Tests
//
//  Created by Ndriqim Nagavci on 27/10/2022.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import XCTest
@testable import PovioKit

class AttributedStringBuilderTests: XCTestCase {
  func test_apply_addsAttributes() throws {
    let label = UILabel()
    label.text = Values.text
    
    label.bd.apply {
      $0.setTextColor(Values.textColor)
      $0.setFont(Values.font)
      $0.setUnderlineStyle(Values.underlineStyle)
      $0.setParagraphStyle(lineSpacing: Values.paragraphLineSpacing, lineHeight: Values.paragraphLineHeight)
    }
    
    let attributes = try XCTUnwrap(label.attributedText?.attributes(at: 0, effectiveRange: nil))
    let paragraphAttribute = attributes.first(where: {$0.key == .paragraphStyle})

    XCTAssertNotNil(paragraphAttribute, "Attributed string did not add parahraph style")
    XCTAssertEqual(attributes[.foregroundColor] as? UIColor, Values.textColor, "Attributed string did not add color")
    XCTAssertEqual(attributes[.font] as? UIFont, Values.font, "Attributed string did not add font")
    XCTAssertEqual(attributes[.underlineStyle] as? Int, Values.underlineStyle.rawValue, "Attributed string did not add underline style")
  }
  
  func test_apply_addsSubstringAttributes() throws {
    let label = UILabel()
    label.text = Values.text
    
    let range = NSRange(Values.text.range(of: Values.substring)!, in: Values.text)
    
    label.bd.apply {
      $0.setTextColor(Values.textColor, substring: Values.substring)
      $0.setFont(Values.font, substring: Values.substring)
      $0.setUnderlineStyle(Values.underlineStyle, substring: Values.substring)
      $0.setParagraphStyle(lineSpacing: Values.paragraphLineSpacing, lineHeight: Values.paragraphLineHeight, substring: Values.substring)
    }
    
    let attributes = try XCTUnwrap(label.attributedText?.attributes(at: range.lowerBound, effectiveRange: nil))
    let paragraphAttribute = attributes.first(where: {$0.key == .paragraphStyle})

    XCTAssertNotNil(paragraphAttribute, "Attributed string did not add parahraph style for substring")
    XCTAssertEqual(attributes[.foregroundColor] as? UIColor, Values.textColor, "Attributed string did not add color for substring")
    XCTAssertEqual(attributes[.font] as? UIFont, Values.font, "Attributed string did not add font for substring")
    XCTAssertEqual(attributes[.underlineStyle] as? Int, Values.underlineStyle.rawValue, "Attributed string did not add underline style for substring")
  }
  
  func test_apply_addsRangeAttributes() throws {
    let label = UILabel()
    label.text = Values.text
    
    let range = NSRange(Values.text.range(of: Values.substring)!, in: Values.text)
    
    label.bd.apply {
      $0.setTextColor(Values.textColor, range: range)
      $0.setFont(Values.font, range: range)
      $0.setUnderlineStyle(Values.underlineStyle, range: range)
      $0.setParagraphStyle(lineSpacing: Values.paragraphLineSpacing, lineHeight: Values.paragraphLineHeight, range: range)
    }
    
    let attributes = try XCTUnwrap(label.attributedText?.attributes(at: range.lowerBound, effectiveRange: nil))
    let paragraphAttribute = attributes.first(where: {$0.key == .paragraphStyle})

    XCTAssertNotNil(paragraphAttribute, "Attributed string did not add parahraph style for range")
    XCTAssertEqual(attributes[.foregroundColor] as? UIColor, Values.textColor, "Attributed string did not add color for range")
    XCTAssertEqual(attributes[.font] as? UIFont, Values.font, "Attributed string did not add font for range")
    XCTAssertEqual(attributes[.underlineStyle] as? Int, Values.underlineStyle.rawValue, "Attributed string did not add underline style for range")
  }
}

// MARK: - Helpers
private extension AttributedStringBuilderTests {
  enum Values {
    static let text = "My custom text!"
    static let substring = "custom"
    static let textColor: UIColor = .red
    static let font: UIFont = .boldSystemFont(ofSize: 14)
    static let underlineStyle: NSUnderlineStyle = .thick
    static let paragraphLineSpacing: CGFloat = 10
    static let paragraphLineHeight: CGFloat = 30
  }
}
