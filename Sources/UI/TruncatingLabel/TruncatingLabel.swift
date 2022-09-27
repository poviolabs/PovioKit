//
//  TruncatingLabel.swift
//  PovioKit
//
//  Created by Toni K. Turk on 25/08/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import UIKit

// 1. Both strings fit into a single line
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
// 4. There is not enough space for the secondary text
// in the whole line. Truncate primary text in the first line.
//  ---------------------------------------------
// |   This is a long text that has to be sp...  |
// |   secondary label is too long to be disp... |
//  ---------------------------------------------
//
public class TruncatingLabel: UIView {
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
      setNeedsDisplay()
    }
  }
  public var primaryFont: UIFont {
    get {
      primaryTextAttributes[.font]! as! UIFont
    }
    set {
      primaryTextAttributes[.font] = newValue
      internalIntrinsicContentSize = calculateIntrinsicContentSize()
      setNeedsDisplay()
    }
  }
  public var secondaryColor: UIColor {
    get {
      secondaryTextAttributes[.foregroundColor]! as! UIColor
    }
    set {
      secondaryTextAttributes[.foregroundColor] = newValue
      setNeedsDisplay()
    }
  }
  public var secondaryFont: UIFont {
    get {
      secondaryTextAttributes[.font]! as! UIFont
    }
    set {
      secondaryTextAttributes[.font] = newValue
      internalIntrinsicContentSize = calculateIntrinsicContentSize()
      setNeedsDisplay()
    }
  }
  public var gravity: Gravity = .left {
    didSet { setNeedsDisplay() }
  }
  public var primaryText: String = "" {
    didSet { setNeedsDisplay() }
  }
  public var secondaryText: String = "" {
    didSet { setNeedsDisplay() }
  }
  
  private lazy var internalIntrinsicContentSize: CGSize = calculateIntrinsicContentSize()
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    internalIntrinsicContentSize.width = frame.width
    setNeedsDisplay()
  }
  
  public override func draw(_ rect: CGRect) {
    defer {
      invalidateIntrinsicContentSize()
    }
    
    var firstSplitIndex = primaryText.endIndex
    var firstSplitIndexWithDots = primaryText.endIndex
    var lastSpaceIndex: String.Index?
    var primarySize: CGSize = .zero
    
    let offset: CGFloat = 5
    let dots = "..."
    let dotsWidth = (dots as NSString).size(withAttributes: primaryTextAttributes).width
    
    /// find the index at which the primary string would be drawn out of the horizontal boundary.
    for index in primaryText.indices {
      primarySize = (primaryText[...index] as NSString).size(withAttributes: primaryTextAttributes)
      
      if firstSplitIndexWithDots == primaryText.endIndex && (primaryText[..<index] + dots as NSString).size(withAttributes: primaryTextAttributes).width > frame.width {
        firstSplitIndexWithDots = primaryText.index(before: index)
      }
      
      if primarySize.width > frame.width {
        firstSplitIndex = lastSpaceIndex.map(primaryText.index(after:)) ?? primaryText.index(before: index)
        break
      }
      if primaryText[index] == " " { lastSpaceIndex = index }
    }
    
    /// `primary1` is the (sub)string drawn in the first line
    var primary1 = primaryText[..<firstSplitIndex] as NSString
    primarySize = primary1.size(withAttributes: primaryTextAttributes)
    
    /// calculate the length of the secondary string
    var secondaryString = secondaryText as NSString
    let secondarySize = secondaryString.size(withAttributes: secondaryTextAttributes)
    /// available width for remainder of the primary string
    let availableWidth = frame.width - secondarySize.width - offset*2
    
    /// calculate the index at which the remaining part of the primary string would be drawn
    /// over the secondary string
    var secondSplitIndex = firstSplitIndex
    var appendDots = false
    
    var primary2Size: CGSize = .zero
    while true { // @FIXME: - Use for loop?
      guard secondSplitIndex != primaryText.endIndex else { break }
      primary2Size = (primaryText[firstSplitIndex..<secondSplitIndex] as NSString).size(withAttributes: primaryTextAttributes)
      if primary2Size.width + dotsWidth + offset*2 > availableWidth {
        appendDots = true
        if secondSplitIndex != firstSplitIndex {
          secondSplitIndex = primaryText.index(before: secondSplitIndex)
        }
        break
      }
      secondSplitIndex = primaryText.index(after: secondSplitIndex)
    }
    
    /// `primary2` is the substring drawn in the second line
    let primary2 = (primaryText[firstSplitIndex..<secondSplitIndex].trimmingCharacters(in: .whitespaces) + (appendDots ? dots : .init())) as NSString
    
    if primary2.length == 0 && primarySize.width + secondarySize.width + offset*2 <= frame.width {
      /// enough space for both strings in a single line
      
      let secondaryStartPosition = gravity == .left
      ? primarySize.width + offset*2
      : frame.width - secondarySize.width
      
      /// draw the first line (both primary and secondary texts)
      /// i)
      primary1.draw(
        at: .zero,
        withAttributes: primaryTextAttributes
      )
      /// ii)
      secondaryString.draw(
        at: .init(
          x: secondaryStartPosition,
          y: (primarySize.height - secondarySize.height)*0.5),
        withAttributes: secondaryTextAttributes
      )
      
      /// update intrinsic content size (the height is just the maximum of height of both texts)
      internalIntrinsicContentSize = .init(
        width: frame.width,
        height: max(primarySize.height, secondarySize.height)
      )
      return
    }
    
    var secondaryStartPosition = gravity == .left
    ? (primary2.length == 0 ? 0 : primary2.size(withAttributes: primaryTextAttributes).width + offset*2)
    : frame.width - secondarySize.width
    
    if secondarySize.width > frame.width || primary2 == dots as NSString {
      /// there is not enough space for the whole second string, therefore we have to truncate it
      secondaryStartPosition = 0
      
      if secondaryStartPosition + secondarySize.width > frame.width {
        // @NOTE: - We assume that secondary strings are 'short', so we start from the back
        for index in secondaryText.indices.reversed() {
          secondaryString = (secondaryText[..<index] + dots) as NSString
          guard secondaryString.size(withAttributes: secondaryTextAttributes).width > frame.width else {
            break
          }
        }
      }
      
      if primary2.length > 0 {
        /// because the whole second line must be allocated to the secondary label,
        /// we have to move the dots to the first line
        precondition(primary2 == dots as NSString)
        primary1 = primaryText[..<firstSplitIndexWithDots].trimmingCharacters(in: .whitespaces) + dots as NSString
      }
      /// 1. draw the first line
      primary1.draw(
        at: .zero,
        withAttributes: primaryTextAttributes
      )
      /// 2. draw the second line
      secondaryString.draw(
        at: .init(
          x: secondaryStartPosition,
          y: primarySize.height + offset + (primarySize.height - secondarySize.height)*0.5),
        withAttributes: secondaryTextAttributes
      )
    } else {
      /// 1. draw the first line
      primary1.draw(
        at: .zero,
        withAttributes: primaryTextAttributes
      )
      /// 2. draw the second line
      /// i)
      primary2.draw(
        at: .init(x: 0, y: primarySize.height + offset),
        withAttributes: primaryTextAttributes
      )
      /// ii)
      secondaryString.draw(
        at: .init(
          x: secondaryStartPosition,
          y: primarySize.height + offset + (primarySize.height - secondarySize.height)*0.5),
        withAttributes: secondaryTextAttributes
      )
    }
    
    /// update intrinsic content size
    internalIntrinsicContentSize = .init(
      width: frame.width,
      height: primarySize.height + offset + max(primarySize.height, secondarySize.height)
    )
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

