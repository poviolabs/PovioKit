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
    
    var firstSplitIndex = primaryText.endIndex
    var lastSpaceIndex: String.Index?
    var primarySize: CGSize = .zero
    
    let offset: CGFloat = 5
    let dots = "... "
    
    /// find the index at which the primary string would be drawn out of the horizontal boundary.
    for index in primaryText.indices {
      if primaryText[index] == " " { lastSpaceIndex = index }
      primarySize = (primaryText[..<index] as NSString).size(
        withAttributes: primaryTextAttributes)
      if primarySize.width > frame.width - offset {
        firstSplitIndex = lastSpaceIndex.map(primaryText.index(after:)) ?? index
        break
      }
    }
    
    /// `primary1` is the (sub)string drawn in the first line
    let primary1 = primaryText[..<firstSplitIndex] as NSString
    /// draw the first line
    primary1.draw(at: .zero, withAttributes: primaryTextAttributes)
    
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
      primarySize = (primaryText[firstSplitIndex..<secondSplitIndex] + dots as NSString).size(withAttributes: primaryTextAttributes)
      if primarySize.width > availableWidth {
        appendDots = true
        break
      }
      secondSplitIndex = primaryText.index(after: secondSplitIndex)
    }
    
    /// `primary2` is the substring drawn in the second line
    let primary2 = (primaryText[firstSplitIndex..<secondSplitIndex] + (appendDots ? dots : .init())) as NSString
    
    if firstSplitIndex == secondSplitIndex && primarySize.width + secondarySize.width + offset <= frame.width {
      /// enough space for both strings in a single line
      secondaryString.draw(
        at: .init(
          x: frame.width - secondarySize.width,
          y: (primarySize.height - secondarySize.height)*0.5),
        withAttributes: secondaryTextAttributes)
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
    
    /// draw secondary string
    secondaryString.draw(
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
