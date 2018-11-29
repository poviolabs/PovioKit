//
//  AttributedStringBuilder.swift
//  TSS
//
//  Created by Povio on 04/07/2019.
//  Copyright © 2019 Povio Inc. All rights reserved.
//
import UIKit

public protocol BuilderCompatible: class {
  var attributedText: NSAttributedString? { get set }
  var text: String? { get }
  var bd: Builder { get }
}

extension BuilderCompatible {
  public var bd: Builder { return Builder(self) }
}

extension UILabel: BuilderCompatible {}
extension UITextField: BuilderCompatible {}

public class Builder {
  internal let emptyAttributedString = NSAttributedString(string: "")
  private let compatible: BuilderCompatible?
  
  public init() {
    self.compatible = nil
  }
  
  public init(_ compatible: BuilderCompatible?) {
    self.compatible = compatible
  }
  
  @discardableResult
  open func apply(on text: String, _ closure: (AttributedStringBuilder) -> Void) -> NSAttributedString {
    let builder = AttributedStringBuilder(text: text)
    closure(builder)
    let attributedString = builder.create()
    compatible?.attributedText = attributedString
    return attributedString
  }
  
  @discardableResult
  open func apply(_ closure: (AttributedStringBuilder) -> Void) -> NSAttributedString {
    let builder = AttributedStringBuilder(text: compatible?.text ?? "")
    closure(builder)
    let attributedString = builder.create()
    compatible?.attributedText = attributedString
    return attributedString
  }
}

open class AttributedStringBuilder {
  private enum StringBuilderError: Error {
    case invalidRange
    case substringNotFound
    
    var localizedTitle: String? {
      return "Error"
    }
  }
  
  let text: String
  private var attributes = [NSAttributedString.Key: Any]()
  private var rangeAttributes = [(NSAttributedString.Key, Any, NSRange)]()
  
  public init(text: String) {
    self.text = text
  }
}

// MARK: - Custom initializers
extension AttributedStringBuilder {
  open func create() -> NSAttributedString {
    if rangeAttributes.isEmpty {
      return NSAttributedString(string: text, attributes: attributes)
    }
    return createMutable() as NSAttributedString
  }
  
  open func createMutable() -> NSMutableAttributedString {
    let mutableString = NSMutableAttributedString(string: text, attributes: attributes)
    for (key, value, range) in rangeAttributes {
      mutableString.addAttribute(key, value: value, range: range)
    }
    return mutableString
  }
}

// MARK: - Add Attribute Setters
extension AttributedStringBuilder {
  @discardableResult
  open func addAttribute(key: NSAttributedString.Key, object: Any?) -> AttributedStringBuilder {
    if let object = object {
      attributes[key] = object
    }
    return self
  }
  
  @discardableResult
  open func addAttribute(key: NSAttributedString.Key, object: Any?, range: NSRange) throws -> AttributedStringBuilder {
    try validate(range: range)
    if let object = object {
      rangeAttributes.append((key, object, range))
    }
    return self
  }
  
  @discardableResult
  open func addAttribute(key: NSAttributedString.Key, object: Any?, substring: String) throws -> AttributedStringBuilder {
    guard let range = text.range(of: substring) else { throw StringBuilderError.substringNotFound }
    return try addAttribute(key: key, object: object, range: NSRange(range, in: text))
  }
}

// MARK: - Other Setters
extension AttributedStringBuilder {
  @discardableResult
  open func setFont(_ font: UIFont?) -> AttributedStringBuilder {
    return addAttribute(key: .font, object: font)
  }
  
  @discardableResult
  open func setTextColor(_ color: UIColor?) -> AttributedStringBuilder {
    return addAttribute(key: .foregroundColor, object: color)
  }
  
  @discardableResult
  open func setUnderlineStyle(_ style: NSUnderlineStyle) -> AttributedStringBuilder {
    return addAttribute(key: .underlineStyle, object: style.rawValue)
  }
  
  @discardableResult
  open func setParagraphStyle(lineSpacing: CGFloat,
                         heightMultiple: CGFloat = 1,
                         lineHeight: CGFloat,
                         lineBreakMode: NSLineBreakMode = .byWordWrapping,
                         textAlignment: NSTextAlignment = .left) -> AttributedStringBuilder {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = lineSpacing
    paragraphStyle.lineHeightMultiple = heightMultiple
    paragraphStyle.minimumLineHeight = lineHeight
    paragraphStyle.lineBreakMode = lineBreakMode
    paragraphStyle.alignment = textAlignment
    return addAttribute(key: .paragraphStyle, object: paragraphStyle)
  }
  
  @discardableResult
  open func setFont(_ font: UIFont?, range: NSRange) throws -> AttributedStringBuilder {
    return try addAttribute(key: .font, object: font, range: range)
  }
  
  @discardableResult
  open func setTextColor(_ color: UIColor?, range: NSRange) throws  -> AttributedStringBuilder {
    return try addAttribute(key: .foregroundColor, object: color, range: range)
  }
  
  @discardableResult
  open func setUnderlineStyle(_ style: NSUnderlineStyle, range: NSRange) throws  -> AttributedStringBuilder {
    return try addAttribute(key: .underlineStyle, object: style.rawValue, range: range)
  }
  
  @discardableResult
  open func setParagraphStyle(lineSpacing: CGFloat,
                         heightMultiple: CGFloat = 1,
                         lineHeight: CGFloat,
                         lineBreakMode: NSLineBreakMode = .byWordWrapping,
                         textAlignment: NSTextAlignment = .left,
                         range: NSRange) throws -> AttributedStringBuilder {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = lineSpacing
    paragraphStyle.lineHeightMultiple = heightMultiple
    paragraphStyle.minimumLineHeight = lineHeight
    paragraphStyle.lineBreakMode = lineBreakMode
    paragraphStyle.alignment = textAlignment
    return try addAttribute(key: .paragraphStyle, object: paragraphStyle, range: range)
  }
  
  @discardableResult
  open func setFont(_ font: UIFont?, substring: String) throws -> AttributedStringBuilder {
    return try addAttribute(key: .font, object: font, substring: substring)
  }
  
  @discardableResult
  open func setTextColor(_ color: UIColor?, substring: String) throws  -> AttributedStringBuilder {
    return try addAttribute(key: .foregroundColor, object: color, substring: substring)
  }
  
  @discardableResult
  open func setUnderlineStyle(_ style: NSUnderlineStyle, substring: String) throws  -> AttributedStringBuilder {
    return try addAttribute(key: .underlineStyle, object: style.rawValue, substring: substring)
  }
  
  @discardableResult
  open func setParagraphStyle(lineSpacing: CGFloat,
                         heightMultiple: CGFloat = 1,
                         lineHeight: CGFloat,
                         lineBreakMode: NSLineBreakMode = .byWordWrapping,
                         textAlignment: NSTextAlignment = .left,
                         substring: String) throws  -> AttributedStringBuilder {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = lineSpacing
    paragraphStyle.lineHeightMultiple = heightMultiple
    paragraphStyle.minimumLineHeight = lineHeight
    paragraphStyle.lineBreakMode = lineBreakMode
    paragraphStyle.alignment = textAlignment
    return try addAttribute(key: .paragraphStyle, object: paragraphStyle, substring: substring)
  }
}

// MARK: - Private Methods
private extension AttributedStringBuilder {
  func validate(range: NSRange) throws {
    if text.count < range.location + range.length || range.location < 0 {
      throw StringBuilderError.invalidRange
    }
  }
}
