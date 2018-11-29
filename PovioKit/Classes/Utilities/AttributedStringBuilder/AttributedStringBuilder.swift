//
//  AttributedStringBuilder.swift
//  TSS
//
//  Created by Povio on 04/07/2019.
//  Copyright © 2019 Povio Inc. All rights reserved.
//
import UIKit

protocol ParentProtocol: class {
  var attributedText: NSAttributedString? { get set }
  var text: String? { get }
}

class Builder {
  internal let emptyAttributedString = NSAttributedString(string: "")
  private let parent: ParentProtocol?
  
  init() {
    self.parent = nil
  }
  
  init(parent: ParentProtocol?) {
    self.parent = parent
  }
  
  @discardableResult
  func apply(on text: String, _ closure: (AttributedStringBuilder) -> Void) -> NSAttributedString {
    let builder = AttributedStringBuilder(text: text)
    closure(builder)
    let attributedString = builder.create()
    parent?.attributedText = attributedString
    return attributedString
  }
  
  @discardableResult
  func apply(_ closure: (AttributedStringBuilder) -> Void) -> NSAttributedString {
    let builder = AttributedStringBuilder(text: parent?.text ?? "")
    closure(builder)
    let attributedString = builder.create()
    parent?.attributedText = attributedString
    return attributedString
  }
}

var attributedString = Builder().apply(on: "Text") {
  $0.setTextColor(UIColor.white)
  $0.setFont(UIFont.init())
}

extension UILabel: ParentProtocol {
  var bd: Builder { return Builder(parent: self) }
}

extension UITextView: ParentProtocol {
  var attributedText: NSAttributedString? {
    get { return attributedString }
    set { attributedString = attributedText ?? bd.emptyAttributedString }
  }
  
  var text: String? { return attributedString.string }
  var bd: Builder { return Builder(parent: self) }
}

extension UITextField: ParentProtocol {
  var bd: Builder { return Builder(parent: self) }
}

/// AttributedStringBuilder
class AttributedStringBuilder {
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
  
  init(text: String) {
    self.text = text
  }
}

// MARK: - Custom initializers
extension AttributedStringBuilder {
  func create() -> NSAttributedString {
    if rangeAttributes.isEmpty {
      return NSAttributedString(string: text, attributes: attributes)
    }
    return createMutable() as NSAttributedString
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
extension AttributedStringBuilder {
  @discardableResult
  func addAttribute(key: NSAttributedString.Key, object: Any?) -> AttributedStringBuilder {
    if let object = object {
      attributes[key] = object
    }
    return self
  }
  
  @discardableResult
  func addAttribute(key: NSAttributedString.Key, object: Any?, range: NSRange) throws -> AttributedStringBuilder {
    try validate(range: range)
    if let object = object {
      rangeAttributes.append((key, object, range))
    }
    return self
  }
  
  @discardableResult
  func addAttribute(key: NSAttributedString.Key, object: Any?, substring: String) throws -> AttributedStringBuilder {
    guard let range = text.range(of: substring) else { throw StringBuilderError.substringNotFound }
    return try addAttribute(key: key, object: object, range: NSRange(range, in: text))
  }
}

// MARK: - Other Setters
extension AttributedStringBuilder {
  @discardableResult
  func setFont(_ font: UIFont?) -> AttributedStringBuilder {
    return addAttribute(key: .font, object: font)
  }
  
  @discardableResult
  func setTextColor(_ color: UIColor?) -> AttributedStringBuilder {
    return addAttribute(key: .foregroundColor, object: color)
  }
  
  @discardableResult
  func setUnderlineStyle(_ style: Int?) -> AttributedStringBuilder {
    return addAttribute(key: .underlineStyle, object: style)
  }
  
  @discardableResult
  func setParagraphStyle(lineSpacing: CGFloat,
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
  func setFont(_ font: UIFont?, range: NSRange) throws -> AttributedStringBuilder {
    return try addAttribute(key: .font, object: font, range: range)
  }
  
  @discardableResult
  func setTextColor(_ color: UIColor?, range: NSRange) throws  -> AttributedStringBuilder {
    return try addAttribute(key: .foregroundColor, object: color, range: range)
  }
  
  @discardableResult
  func setUnderlineStyle(_ style: Int?, range: NSRange) throws  -> AttributedStringBuilder {
    return try addAttribute(key: .underlineStyle, object: style, range: range)
  }
  
  @discardableResult
  func setParagraphStyle(lineSpacing: CGFloat,
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
  func setFont(_ font: UIFont?, substring: String) throws -> AttributedStringBuilder {
    return try addAttribute(key: .font, object: font, substring: substring)
  }
  
  @discardableResult
  func setTextColor(_ color: UIColor?, substring: String) throws  -> AttributedStringBuilder {
    return try addAttribute(key: .foregroundColor, object: color, substring: substring)
  }
  
  @discardableResult
  func setUnderlineStyle(_ style: Int?, substring: String) throws  -> AttributedStringBuilder {
    return try addAttribute(key: .underlineStyle, object: style, substring: substring)
  }
  
  @discardableResult
  func setParagraphStyle(lineSpacing: CGFloat,
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
