//
//  TruncatingLabel.swift
//  PovioKit
//
//  Created by Toni K. Turk on 25/08/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import UIKit

// 1. Boths string fit into a single line
//  ---------------------------------------------
// |   This is a short text.   secondary label   |
//  ---------------------------------------------
//
// 2. Strings do not fit into a single line, however,
// there is enough space for both of them in two lines.
//  ---------------------------------------------
// |   This is a longer single-line text.        |
// |                           secondary label   |
//  ---------------------------------------------
//
//  ---------------------------------------------
// |   This is a longer two-line text, lorem     |
// |   ipsum dolor.            secondary label   |
//  ---------------------------------------------
//
// 3. Strings do not fit into a single line and there is also
// not enough space for the primary string in the second line.
// Primary string, therefore, has to be truncated with '...'.
//  ---------------------------------------------
// |   This is a long text that has to be split  |
// |   into two lines, ho...    secondary label  |
//  ---------------------------------------------
//
public class TruncatingLabel: UIView {
  // @NOTE: - For performance reasons, it is the responsibility of the
  // user to call `setNeedsDisplay()` on the view after modifying attributes.
  
  // @NOTE: - For autolayout to work properly, at least the width of the view
  // should be 'statically' determined (that is, layoutSubviews() should
  // receive a frame with valid width) by the constraint setup, i.e., bind
  // the leading and trailing constraints to the parent view. The height of the
  // view is dynamic and the intrinsic content size updated accordingly.
  
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
      internalIntrinsicContentSize = calculateIntrinsicContentSize()
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
      internalIntrinsicContentSize = calculateIntrinsicContentSize()
    }
  }
  public var gravity: Gravity = .left
  public var primaryText: String = ""
  public var secondaryText: String = ""
  
  private lazy var internalIntrinsicContentSize: CGSize = calculateIntrinsicContentSize()
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    internalIntrinsicContentSize.width = frame.width
    setNeedsDisplay()
  }
  
  public override func draw(_ rect: CGRect) {
    defer {
      invalidateIntrinsicContentSize()
      print(intrinsicContentSize)
    }
    
    var firstSplitIndex = primaryText.endIndex
    var lastSpaceIndex: String.Index?
    var primarySize: CGSize = .zero
    
    let offset: CGFloat = 5
    let dots = "... "
    let dotsWidth = (dots as NSString).size(withAttributes: primaryTextAttributes).width
    
    /// find the index at which the primary string would be drawn out of the horizontal boundary.
    for index in primaryText.indices {
      if primaryText[index] == " " { lastSpaceIndex = index }
      primarySize = (primaryText[..<index] as NSString).size(
        withAttributes: primaryTextAttributes)
      if primarySize.width > frame.width - offset*2 {
        firstSplitIndex = lastSpaceIndex.map(primaryText.index(after:)) ?? index
        break
      }
    }
    
    /// `primary1` is the (sub)string drawn in the first line
    let primary1 = primaryText[..<firstSplitIndex] as NSString
    primarySize = primary1.size(withAttributes: primaryTextAttributes)
    /// draw the first line
    primary1.draw(
      at: .zero,
      withAttributes: primaryTextAttributes
    )
    
    /// calculate the length of the secondary string
    let secondaryString = secondaryText as NSString
    let secondarySize = secondaryString.size(withAttributes: secondaryTextAttributes)
    /// available width for remainder of the primary string
    let availableWidth = frame.width - secondarySize.width - offset*2
    
    /// calculate the index at which the remaining part of the primary string would be drawn
    /// over the secondary string
    var secondSplitIndex = firstSplitIndex
    var appendDots = false
    while true { // @FIXME: - Use for loop?
      guard secondSplitIndex != primaryText.endIndex else { break }
      primarySize = (primaryText[firstSplitIndex..<secondSplitIndex] as NSString).size(withAttributes: primaryTextAttributes)
      if primarySize.width + dotsWidth + offset*2 > availableWidth {
        appendDots = true
        break
      }
      secondSplitIndex = primaryText.index(after: secondSplitIndex)
    }
    
    /// `primary2` is the substring drawn in the second line
    let primary2 = (primaryText[firstSplitIndex..<secondSplitIndex] + (appendDots ? dots : .init())) as NSString
    
    if firstSplitIndex == secondSplitIndex && primarySize.width + secondarySize.width + offset*2 <= frame.width {
      /// enough space for both strings in a single line
      
      let secondaryStartPosition = gravity == .left
      ? primarySize.width + offset*2
      : frame.width - secondarySize.width
      
      secondaryString.draw(
        at: .init(
          x: secondaryStartPosition,
          y: (primarySize.height - secondarySize.height)*0.5),
        withAttributes: secondaryTextAttributes
      )
      internalIntrinsicContentSize = .init(
        width: frame.width,
        height: max(primarySize.height, secondarySize.height))
      return
    }
    
    /// draw the second line
    primary2.draw(
      at: .init(x: 0, y: primarySize.height + offset),
      withAttributes: primaryTextAttributes
    )
    
    let secondaryStartPosition = gravity == .left
    ? (primary2.length == 0 ? 0 : primary2.size(withAttributes: primaryTextAttributes).width + offset*2)
    : frame.width - secondarySize.width
    
    /// draw secondary string
    secondaryString.draw(
      at: .init(
        x: secondaryStartPosition,
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

public extension TruncatingLabel {
  // @NOTE: - Control the alignment of the secondary text:
  // When set to `left`, the secondary label will gravitate toward
  // left (either touching primary text or the left edge):
  //  -------------------------------------------
  // |   This is a short text. secondary label   |
  //  -------------------------------------------
  //  -------------------------------------------
  // |   This is a longer single-line text.      |
  // |   secondary label                         |
  //  -------------------------------------------
  //  -------------------------------------------
  // |   This is a longer two-line text, lorem   |
  // |   ipsum dolor. secondary label            |
  //  -------------------------------------------
  //
  // When set to `right`, the secondary label will gravitate toward
  // right:
  //  -------------------------------------------
  // |  This is a short text.   secondary label  |
  //  -------------------------------------------
  //  -------------------------------------------
  // |  This is a longer single-line text.       |
  // |                          secondary label  |
  //  -------------------------------------------
  //  -------------------------------------------
  // |  This is a longer two-line text, lorem    |
  // |  ipsum dolor.            secondary label  |
  //  -------------------------------------------
  enum Gravity {
    case left, right
  }
}

extension TruncatingLabel {
  func calculateIntrinsicContentSize() -> CGSize {
    .init(
      width: UIScreen.main.bounds.width,
      height: primaryFont.lineHeight + secondaryFont.lineHeight + 10
    )
  }
}
