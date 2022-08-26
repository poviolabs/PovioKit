//
//  File.swift
//  
//
//  Created by Toni K. Turk on 25/08/2022.
//

import UIKit

public class TwoLineLabel: UIView {
  private var primaryTextAttributes: [NSAttributedString.Key: Any] = [
    .font: UIFont.systemFont(ofSize: 14),
    .foregroundColor: UIColor.gray
  ]
  private var secondaryTextAttributes: [NSAttributedString.Key: Any] = [
    .font: UIFont.systemFont(ofSize: 12),
    .foregroundColor: UIColor.blue
  ]
  
  public var primaryColor: UIColor {
    get {
      primaryTextAttributes[.foregroundColor]! as! UIColor
    }
    set {
      primaryTextAttributes[.foregroundColor] = newValue
    }
  }
  public var primaryFont: UIFont {
    get {
      primaryTextAttributes[.font]! as! UIFont
    }
    set {
      primaryTextAttributes[.font] = newValue
    }
  }
  public var secondaryColor: UIColor {
    get {
      secondaryTextAttributes[.foregroundColor]! as! UIColor
    }
    set {
      secondaryTextAttributes[.foregroundColor] = newValue
    }
  }
  public var secondaryFont: UIFont {
    get {
      secondaryTextAttributes[.font]! as! UIFont
    }
    set {
      primaryTextAttributes[.font] = newValue
    }
  }
  public var primaryText: String = ""
  public var secondaryText: String = ""
  
  private var intrinsic: CGSize = .zero
  
  public override func draw(_ rect: CGRect) {
    defer { invalidateIntrinsicContentSize() }
    
    var index = primaryText.startIndex
    var lastSpaceIndex: String.Index?
    var bounding: CGSize!
    while true {
      guard index != primaryText.endIndex else { break }
      if primaryText[index] == " " { lastSpaceIndex = index }
      bounding = NSString(string: String(primaryText[..<index])).size(
        withAttributes: primaryTextAttributes)
      if bounding.width > frame.width - 5 {
        index = primaryText.index(after: lastSpaceIndex ?? index)
        break
      }
      index = primaryText.index(after: index)
    }
    
//    if index == primaryText.startIndex {
//      // there is enough space for the whole string
//      // in a single line
//    }
    
    let primary1 = NSString(string: String(primaryText[..<index]))
    let secondarySize = NSString(string: secondaryText).size(withAttributes: secondaryTextAttributes)
    
    var newIndex = index
    while true {
      guard newIndex != primaryText.endIndex else { break }
      bounding = NSString(string: String(primaryText[index..<newIndex]) + "... ").size(
        withAttributes: primaryTextAttributes)
      if bounding.width > frame.width - secondarySize.width - 10 {
        break
      }
      newIndex = primaryText.index(after: newIndex)
    }
    
    let offset: CGFloat = 5
    let append = bounding.width > frame.width - secondarySize.width - 10 ? "... " : ""
    let primary2 = NSString(string: String(primaryText[index..<newIndex]) + append)
    primary1.draw(at: .zero, withAttributes: primaryTextAttributes)
    if index != newIndex {
      primary2.draw(at: .init(x: 0, y: bounding.height + offset), withAttributes: primaryTextAttributes)
    }
    
    if index == newIndex && bounding.width + secondarySize.width + offset <= frame.width {
      // enough space for both strings in a single line
      NSString(string: secondaryText).draw(
        at: .init(x: frame.width - secondarySize.width, y: 0),
        withAttributes: secondaryTextAttributes)
      intrinsic = .init(
        width: frame.width,
        height: max(bounding.height, secondarySize.height))
      return
    }
    
    NSString(string: secondaryText).draw(
      at: .init(x: frame.width - secondarySize.width, y: bounding.height + offset),
      withAttributes: secondaryTextAttributes)
    intrinsic = .init(width: frame.width, height: bounding.height + offset + max(bounding.height, secondarySize.height))
  }
  
  public override var intrinsicContentSize: CGSize {
    intrinsic
  }
  
  public init() {
    super.init(frame: .zero)
    backgroundColor = .white
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
