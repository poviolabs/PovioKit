//
//  AttributedStringBuilder.swift
//  PovioKit
//
//  Created by Toni Kocjan on 26/04/2019.
//  Copyright © 2020 Povio Labs. All rights reserved.
//

import UIKit

public class AttributedStringBuilder {
  let text: String
  
  private var attributes = [NSAttributedString.Key: Any]()
  private var rangeAttributes = [(NSAttributedString.Key, Any, NSRange)]()
  
  public init(text: String) {
    self.text = text
  }
}

public extension AttributedStringBuilder {
  enum Error: Swift.Error {
    case invalidRange
    case substringNotFound
  }
}

// MARK: - Factory
public extension AttributedStringBuilder {
  func create() -> NSAttributedString {
    if rangeAttributes.isEmpty {
      return .init(string: text, attributes: attributes)
    }
    return createMutable()
  }
  
  func createMutable() -> NSMutableAttributedString {
    let mutableString = NSMutableAttributedString(string: text, attributes: attributes)
    for (key, value, range) in rangeAttributes {
      mutableString.addAttribute(key, value: value, range: range)
    }
    return mutableString
  }
}

// MARK: - Add Attribute Setters
public extension AttributedStringBuilder {
  @discardableResult
  func addAttribute(key: NSAttributedString.Key, object: Any?) -> AttributedStringBuilder {
    if let object = object {
      attributes[key] = object
    }
    return self
  }
  
  @discardableResult
  func addAttribute(key: NSAttributedString.Key, object: Any?, range: NSRange) -> AttributedStringBuilder {
    guard validate(range: range) else { return self }
    if let object = object {
      rangeAttributes.append((key, object, range))
    }
    return self
  }
  
  @discardableResult
  func addAttribute(key: NSAttributedString.Key, object: Any?, substring: String) -> AttributedStringBuilder {
    guard let range = text.range(of: substring) else { return self }
    return addAttribute(key: key, object: object, range: NSRange(range, in: text))
  }
}

// MARK: - Other Setters
public extension AttributedStringBuilder {
  @discardableResult
  func setFont(_ font: UIFont?) -> AttributedStringBuilder {
    addAttribute(key: .font, object: font)
  }
  
  @discardableResult
  func setTextColor(_ color: UIColor?) -> AttributedStringBuilder {
    addAttribute(key: .foregroundColor, object: color)
  }
  
  @discardableResult
  func setUnderlineStyle(_ style: NSUnderlineStyle) -> AttributedStringBuilder {
    addAttribute(key: .underlineStyle, object: style.rawValue)
  }
  
  @discardableResult
  func setParagraphStyle(
    lineSpacing: CGFloat,
    heightMultiple: CGFloat = 1,
    lineHeight: CGFloat,
    lineBreakMode: NSLineBreakMode = .byWordWrapping,
    textAlignment: NSTextAlignment = .left
  ) -> AttributedStringBuilder {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = lineSpacing
    paragraphStyle.lineHeightMultiple = heightMultiple
    paragraphStyle.minimumLineHeight = lineHeight
    paragraphStyle.lineBreakMode = lineBreakMode
    paragraphStyle.alignment = textAlignment
    return addAttribute(key: .paragraphStyle, object: paragraphStyle)
  }
  
  @discardableResult
  func setFont(_ font: UIFont?, range: NSRange) -> AttributedStringBuilder {
    addAttribute(key: .font, object: font, range: range)
  }
  
  @discardableResult
  func setTextColor(_ color: UIColor?, range: NSRange) -> AttributedStringBuilder {
    addAttribute(key: .foregroundColor, object: color, range: range)
  }
  
  @discardableResult
  func setUnderlineStyle(_ style: NSUnderlineStyle, range: NSRange) -> AttributedStringBuilder {
    addAttribute(key: .underlineStyle, object: style.rawValue, range: range)
  }
  
  @discardableResult
  func setParagraphStyle(
    lineSpacing: CGFloat,
    heightMultiple: CGFloat = 1,
    lineHeight: CGFloat,
    lineBreakMode: NSLineBreakMode = .byWordWrapping,
    textAlignment: NSTextAlignment = .left,
    range: NSRange
  ) -> AttributedStringBuilder {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = lineSpacing
    paragraphStyle.lineHeightMultiple = heightMultiple
    paragraphStyle.minimumLineHeight = lineHeight
    paragraphStyle.lineBreakMode = lineBreakMode
    paragraphStyle.alignment = textAlignment
    return addAttribute(key: .paragraphStyle, object: paragraphStyle, range: range)
  }
  
  @discardableResult
  func setFont(_ font: UIFont?, substring: String) -> AttributedStringBuilder {
    addAttribute(key: .font, object: font, substring: substring)
  }
  
  @discardableResult
  func setTextColor(_ color: UIColor?, substring: String) -> AttributedStringBuilder {
    addAttribute(key: .foregroundColor, object: color, substring: substring)
  }
  
  @discardableResult
  func setUnderlineStyle(_ style: NSUnderlineStyle, substring: String) -> AttributedStringBuilder {
    addAttribute(key: .underlineStyle, object: style.rawValue, substring: substring)
  }
  
  @discardableResult
  func setParagraphStyle(
    lineSpacing: CGFloat,
    heightMultiple: CGFloat = 1,
    lineHeight: CGFloat,
    lineBreakMode: NSLineBreakMode = .byWordWrapping,
    textAlignment: NSTextAlignment = .left,
    substring: String
  ) -> AttributedStringBuilder {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = lineSpacing
    paragraphStyle.lineHeightMultiple = heightMultiple
    paragraphStyle.minimumLineHeight = lineHeight
    paragraphStyle.lineBreakMode = lineBreakMode
    paragraphStyle.alignment = textAlignment
    return addAttribute(key: .paragraphStyle, object: paragraphStyle, substring: substring)
  }
}

// MARK: - Private Methods
private extension AttributedStringBuilder {
  func validate(range: NSRange) -> Bool {
    if text.count < range.location + range.length || range.location < 0 {
      return false
    }
    return true
  }
}

public protocol BuilderCompatible: AnyObject {
  var attributedText: NSAttributedString? { get set }
  var text: String? { get }
}

public extension BuilderCompatible {
  var bd: AttributedStringBuilder.Builder { .init(self) }
}

public extension AttributedStringBuilder {
  class Builder {
    let compatible: BuilderCompatible
    
    public init(_ compatible: BuilderCompatible) {
      self.compatible = compatible
    }
    
    @discardableResult
    public func apply(
      on text: String,
      _ closure: (AttributedStringBuilder) -> Void
    ) -> NSAttributedString {
      let builder = AttributedStringBuilder(text: text)
      closure(builder)
      let attributedString = builder.create()
      compatible.attributedText = attributedString
      return attributedString
    }
    
    @discardableResult
    public func apply(_ closure: (AttributedStringBuilder) -> Void) -> NSAttributedString {
      let builder = AttributedStringBuilder(text: compatible.text ?? "")
      closure(builder)
      let attributedString = builder.create()
      compatible.attributedText = attributedString
      return attributedString
    }
  }
}
