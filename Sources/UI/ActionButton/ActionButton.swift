//
//  GenericButton.swift
//  PovioKit
//
//  Created by Arlind Dushi on 3/17/22.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import SwiftUI

private class ActionButtonViewModel: ObservableObject {
  @Published public var title: String = "Button"
  @Published public var font: Font = .system(size: 16)
  @Published public var textColor: Color = .white
  @Published public var cornerRadius: ActionButton.CornerRadiusType = .rounded
  @Published public var backgroundType = ActionButton.Background.plain(.blue)
  @Published public var borderColor: Color = .clear
  @Published public var borderWidth: CGFloat = 0
  @Published public var leftImage: ActionButton.ExtraImage?
  @Published public var rightImage: ActionButton.ExtraImage?
  @Published public var titleLeftImage: ActionButton.ExtraImage?
  @Published public var titleRightImage: ActionButton.ExtraImage?
  @Published public var actionHandler: (() -> Void)?
}

struct ActionButton: View {
  @ObservedObject private var properties = ActionButtonViewModel()
  
  public init() {}
  public init(action: @escaping (() -> Void)) {
    properties.actionHandler = action
  }
  
  public enum Background {
    case plain(Color)
    case linearGradient(LinearGradient)
    case radialGradient(RadialGradient)
    case angularGradient(AngularGradient)
  }
  
  public var body: some View {
    Button(action: {
      properties.actionHandler?()
    }) {
      HStack {
        properties.leftImage?.image
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: properties.leftImage?.size.width,
                 height: properties.leftImage?.size.height)
        Spacer()
        HStack {
          properties.titleLeftImage?.image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: properties.titleLeftImage?.size.width,
                   height: properties.titleLeftImage?.size.height)
          Text(properties.title)
            .font(properties.font)
          properties.titleRightImage?.image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: properties.titleRightImage?.size.width,
                   height: properties.titleRightImage?.size.height)
        }
        Spacer()
        properties.rightImage?.image
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: properties.rightImage?.size.width,
                 height: properties.rightImage?.size.height)
      }
      .padding()
      .background(backgroundView)
      .foregroundColor(properties.textColor)
      .cornerRadius(getCornerRadius(for: properties.cornerRadius))
      .overlay(
        RoundedRectangle(cornerRadius: getCornerRadius(for: properties.cornerRadius))
          .stroke(properties.borderColor, lineWidth: properties.borderWidth)
      )
      
    }
    .buttonStyle(.plain)
  }
}

// MARK: - Public Properties
extension ActionButton {
  struct ExtraImage {
    let image: Image
    let size: CGSize
  }
  
  enum CornerRadiusType {
    case rounded
    case custom(CGFloat)
  }
}

// MARK: - Builder Pattern Methods
extension ActionButton {
  func title(_ title: String) -> ActionButton {
    self.properties.title = title
    return self
  }
  
  func font(_ font: Font) -> ActionButton {
    self.properties.font = font
    return self
  }
  
  func textColor(_ textColor: Color) -> ActionButton {
    self.properties.textColor = textColor
    return self
  }
  
  func cornerRadius(_ cornerRadius: ActionButton.CornerRadiusType) -> ActionButton {
    self.properties.cornerRadius = cornerRadius
    return self
  }
  
  func backgroundType(_ backgroundType: ActionButton.Background) -> ActionButton {
    self.properties.backgroundType = backgroundType
    return self
  }
  
  func borderColor(_ borderColor: Color) -> ActionButton {
    self.properties.borderColor = borderColor
    return self
  }
  
  func borderWidth(_ borderWidth: CGFloat) -> ActionButton {
    self.properties.borderWidth = borderWidth
    return self
  }
  
  func extraImage(leftImage: ActionButton.ExtraImage) -> ActionButton {
    self.properties.leftImage = leftImage
    return self
  }
  
  func extraImage(rightImage: ActionButton.ExtraImage) -> ActionButton {
    self.properties.rightImage = rightImage
    return self
  }
  
  func extraImage(titleLeftImage: ActionButton.ExtraImage) -> ActionButton {
    self.properties.titleLeftImage = titleLeftImage
    return self
  }
  
  func extraImage(titleRightImage: ActionButton.ExtraImage) -> ActionButton {
    self.properties.titleRightImage = titleRightImage
    return self
  }
}

// MARK: - Access to properties from UIKit
extension ActionButton {
  var title: String {
    get { properties.title }
    set { properties.title = newValue}
  }
  
  var font: Font {
    get { properties.font }
    set { properties.font = newValue}
  }
  
  var textColor: Color {
    get { properties.textColor }
    set { properties.textColor = newValue}
  }
  
  var cornerRadius: ActionButton.CornerRadiusType {
    get { properties.cornerRadius }
    set { properties.cornerRadius = newValue}
  }
  
  var backgroundType: ActionButton.Background {
    get { properties.backgroundType }
    set { properties.backgroundType = newValue}
  }
  
  var borderColor: Color {
    get { properties.borderColor }
    set { properties.borderColor = newValue}
  }
  
  var borderWidth: CGFloat {
    get { properties.borderWidth }
    set { properties.borderWidth = newValue}
  }
  
  var leftImage: ActionButton.ExtraImage? {
    get { properties.leftImage }
    set { properties.leftImage = newValue}
  }
  
  var rightImage: ActionButton.ExtraImage? {
    get { properties.rightImage }
    set { properties.rightImage = newValue}
  }
  
  var titleLeftImage: ActionButton.ExtraImage? {
    get { properties.titleLeftImage }
    set { properties.titleLeftImage = newValue}
  }
  
  var titleRightImage: ActionButton.ExtraImage? {
    get { properties.titleRightImage }
    set { properties.titleRightImage = newValue}
  }
  
  mutating func addAction(_ action: @escaping () -> Void) {
    properties.actionHandler = action
  }
}

// MARK: - Helper Methods
private extension ActionButton {
  @ViewBuilder
  private var backgroundView: some View {
    switch properties.backgroundType {
    case .plain(let backgroundColor):
      backgroundColor
    case let .linearGradient(gradient):
      gradient
    case let .angularGradient(gradient):
      gradient
    case let .radialGradient(gradient):
      gradient
    }
  }
  
  private func getCornerRadius(for cornerType: CornerRadiusType) -> CGFloat {
    switch cornerType {
    case .rounded:
      return .infinity
    case .custom(let cornerRadius):
      return cornerRadius
    }
  }
}

struct ActionButton_Previews: PreviewProvider {
  static var previews: some View {
    ActionButton()
  }
}
