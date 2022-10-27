//
//  AttributedStringBuilderTests.swift
//  PovioKit_Tests
//
//  Created by Ndriqim Nagavci on 27/10/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import XCTest
@testable import PovioKit

class AttributedStringBuilderTests: XCTestCase {
  let text = "My custom text!"
  let substring = "custom"
  let textColor: UIColor = .red
  let font: UIFont = .boldSystemFont(ofSize: 14)
  let underlineStyle: NSUnderlineStyle = .thick
  let paragraphLineSpacing: CGFloat = 10
  let paragraphLineHeight: CGFloat = 30
  
  func test_apply_addsAttributes() throws {
    let label = UILabel()
    label.text = text
    
    label.bd.apply {
      $0.setTextColor(textColor)
      $0.setFont(font)
      $0.setUnderlineStyle(underlineStyle)
      $0.setParagraphStyle(lineSpacing: paragraphLineSpacing, lineHeight: paragraphLineHeight)
    }
    
    let attributes = try XCTUnwrap(label.attributedText?.attributes(at: 0, effectiveRange: nil))
    let paragraphAttribute = attributes.first(where: {$0.key == .paragraphStyle})

    XCTAssertNotNil(paragraphAttribute, "Attributed string did not add parahraph style")
    XCTAssertEqual(attributes[.foregroundColor] as? UIColor, textColor, "Attributed string did not add color")
    XCTAssertEqual(attributes[.font] as? UIFont, font, "Attributed string did not add font")
    XCTAssertEqual(attributes[.underlineStyle] as? Int, underlineStyle.rawValue, "Attributed string did not add underline style")
  }
  
  func test_apply_addsSubstringAttributes() throws {
    let label = UILabel()
    label.text = text
    
    let range = NSRange(text.range(of: substring)!, in: text)
    
    label.bd.apply {
      $0.setTextColor(textColor, substring: substring)
      $0.setFont(font, substring: substring)
      $0.setUnderlineStyle(underlineStyle, substring: substring)
      $0.setParagraphStyle(lineSpacing: paragraphLineSpacing, lineHeight: paragraphLineHeight, substring: substring)
    }
    
    let attributes = try XCTUnwrap(label.attributedText?.attributes(at: range.lowerBound, effectiveRange: nil))
    let paragraphAttribute = attributes.first(where: {$0.key == .paragraphStyle})

    XCTAssertNotNil(paragraphAttribute, "Attributed string did not add parahraph style for substring")
    XCTAssertEqual(attributes[.foregroundColor] as? UIColor, textColor, "Attributed string did not add color for substring")
    XCTAssertEqual(attributes[.font] as? UIFont, font, "Attributed string did not add font for substring")
    XCTAssertEqual(attributes[.underlineStyle] as? Int, underlineStyle.rawValue, "Attributed string did not add underline style for substring")
  }
  
  func test_apply_addsRangeAttributes() throws {
    let label = UILabel()
    label.text = text
    
    let range = NSRange(text.range(of: substring)!, in: text)
    
    label.bd.apply {
      $0.setTextColor(textColor, range: range)
      $0.setFont(font, range: range)
      $0.setUnderlineStyle(underlineStyle, range: range)
      $0.setParagraphStyle(lineSpacing: paragraphLineSpacing, lineHeight: paragraphLineHeight, range: range)
    }
    
    let attributes = try XCTUnwrap(label.attributedText?.attributes(at: range.lowerBound, effectiveRange: nil))
    let paragraphAttribute = attributes.first(where: {$0.key == .paragraphStyle})

    XCTAssertNotNil(paragraphAttribute, "Attributed string did not add parahraph style for range")
    XCTAssertEqual(attributes[.foregroundColor] as? UIColor, textColor, "Attributed string did not add color for range")
    XCTAssertEqual(attributes[.font] as? UIFont, font, "Attributed string did not add font for range")
    XCTAssertEqual(attributes[.underlineStyle] as? Int, underlineStyle.rawValue, "Attributed string did not add underline style for range")
  }
}
