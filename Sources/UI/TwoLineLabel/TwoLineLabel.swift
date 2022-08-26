//
//  TwoLineLabel.swift
//  
//
//  Created by Toni K. Turk on 25/08/2022.
//

import UIKit

public class TwoLineLabel: UIView {
  // @NOTE: - For performance reasons, it is the responsibility of the
  // user to call `setNeedsDisplay()` on the view after modifying attributes.
  
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
  
  private var internalIntrinsicContentSize: CGSize = .zero
  
  public override func draw(_ rect: CGRect) {
    defer { invalidateIntrinsicContentSize() }
    
    var index = primaryText.startIndex
    var lastSpaceIndex: String.Index?
    var primarySize: CGSize = .zero
    while true {
      guard index != primaryText.endIndex else { break }
      if primaryText[index] == " " { lastSpaceIndex = index }
      primarySize = (primaryText[..<index] as NSString).size(
        withAttributes: primaryTextAttributes)
      if primarySize.width > frame.width - 5 {
        index = primaryText.index(after: lastSpaceIndex ?? index)
        break
      }
      index = primaryText.index(after: index)
    }
    
    let primary1 = primaryText[..<index] as NSString
    let secondarySize = (secondaryText as NSString).size(withAttributes: secondaryTextAttributes)
    
    var newIndex = index
    while true {
      guard newIndex != primaryText.endIndex else { break }
      primarySize = (primaryText[index..<newIndex] + "... " as NSString).size(
        withAttributes: primaryTextAttributes)
      if primarySize.width > frame.width - secondarySize.width - 10 {
        break
      }
      newIndex = primaryText.index(after: newIndex)
    }
    
    let offset: CGFloat = 5
    let append = primarySize.width > frame.width - secondarySize.width - 10 ? "... " : ""
    let primary2 = (primaryText[index..<newIndex] + append) as NSString
    primary1.draw(at: .zero, withAttributes: primaryTextAttributes)
    if index != newIndex {
      primary2.draw(
        at: .init(x: 0, y: primarySize.height + offset),
        withAttributes: primaryTextAttributes
      )
    }
    
    if index == newIndex && primarySize.width + secondarySize.width + offset <= frame.width {
      // enough space for both strings in a single line
      (secondaryText as NSString).draw(
        at: .init(
          x: frame.width - secondarySize.width,
          y: (primarySize.height - secondarySize.height)*0.5),
        withAttributes: secondaryTextAttributes)
      internalIntrinsicContentSize = .init(
        width: frame.width,
        height: max(primarySize.height, secondarySize.height))
      return
    }
    
    (secondaryText as NSString).draw(
      at: .init(
        x: frame.width - secondarySize.width,
        y: primarySize.height + offset + (primarySize.height - secondarySize.height)*0.5),
      withAttributes: secondaryTextAttributes)
    internalIntrinsicContentSize = .init(
      width: frame.width,
      height: primarySize.height + offset + max(primarySize.height, secondarySize.height))
  }
  
  public override var intrinsicContentSize: CGSize {
    internalIntrinsicContentSize
  }
  
  public init() {
    super.init(frame: .zero)
    backgroundColor = .white
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
