//
//  GenericButton.swift
//  PovioKit
//
//  Created by Arlind Dushi on 3/17/22.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import SwiftUI

public struct ActionButton: View {
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
      VStack {
        Spacer()
          .frame(minHeight: 1)
        HStack{
          leftView
          Spacer()
          HStack {
            leftTitleView
            Text(title)
              .font(properties.font)
            rightTitleView
          }
          Spacer()
          rightView
        }
        
        Spacer()
          .frame(minHeight: 1)
      }
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

// MARK: - ActionButtonViewModel
private extension ActionButton {
  class ActionButtonViewModel: ObservableObject {
    @Published var title: String = "Button"
    @Published var font: Font = .system(size: 16)
    @Published var textColor: Color = .white
    @Published var cornerRadius: ActionButton.CornerRadiusType = .rounded
    @Published var backgroundType = ActionButton.Background.plain(.blue)
    @Published var borderColor: Color = .clear
    @Published var borderWidth: CGFloat = 0
    @Published var leftImage: ActionButton.ExtraImage?
    @Published var rightImage: ActionButton.ExtraImage?
    @Published var titleLeftImage: ActionButton.ExtraImage?
    @Published var titleRightImage: ActionButton.ExtraImage?
    @Published var actionHandler: (() -> Void)?
  }
}

// MARK: - Public Properties
public extension ActionButton {
  struct ExtraImage {
    let image: Image
    let size: CGSize
    
    public init(image: Image, size: CGSize) {
      self.image = image
      self.size = size
    }
  }
  
  enum CornerRadiusType {
    case rounded
    case custom(CGFloat)
  }
}

// MARK: - Builder Pattern Methods
public extension ActionButton {
  func title(_ title: String) -> ActionButton {
    properties.title = title
    return self
  }
  
  func font(_ font: Font) -> ActionButton {
    properties.font = font
    return self
  }
  
  func textColor(_ textColor: Color) -> ActionButton {
    properties.textColor = textColor
    return self
  }
  
  func cornerRadius(_ cornerRadius: ActionButton.CornerRadiusType) -> ActionButton {
    properties.cornerRadius = cornerRadius
    return self
  }
  
  func backgroundType(_ backgroundType: ActionButton.Background) -> ActionButton {
    properties.backgroundType = backgroundType
    return self
  }
  
  func borderColor(_ borderColor: Color) -> ActionButton {
    properties.borderColor = borderColor
    return self
  }
  
  func borderWidth(_ borderWidth: CGFloat) -> ActionButton {
    properties.borderWidth = borderWidth
    return self
  }
  
  func leftImage(_ leftImage: ActionButton.ExtraImage) -> ActionButton {
    properties.leftImage = leftImage
    return self
  }
  
  func rightImage(_ rightImage: ActionButton.ExtraImage) -> ActionButton {
    properties.rightImage = rightImage
    return self
  }
  
  func titleLeftImage(_ titleLeftImage: ActionButton.ExtraImage) -> ActionButton {
    properties.titleLeftImage = titleLeftImage
    return self
  }
  
  func titleRightImage(_ titleRightImage: ActionButton.ExtraImage) -> ActionButton {
    properties.titleRightImage = titleRightImage
    return self
  }
}

// MARK: - Access to properties from UIKit
public extension ActionButton {
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
  
  func addAction(_ action: @escaping () -> Void) {
    properties.actionHandler = action
  }
}

// MARK: - Helper Methods
private extension ActionButton {
  @ViewBuilder
  private var leftTitleView: some View {
    let titleLeftImage = properties.titleLeftImage
    let titleRightImage = properties.titleRightImage
    
    switch (titleLeftImage, titleRightImage) {
    case (.some(let leftImage), _):
      leftImage
        .image
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: leftImage.size.width,
               height: leftImage.size.height)
    case (.none, .some(let rightImage)):
      Rectangle()
        .fill(Color.clear)
        .frame(width: rightImage.size.width,
               height: rightImage.size.height)
    case (.none, .none):
      EmptyView()
    }
  }
  
  
  @ViewBuilder
  private var rightTitleView: some View {
    let titleLeftImage = properties.titleLeftImage
    let titleRightImage = properties.titleRightImage

    switch (titleLeftImage, titleRightImage) {
    case (_, .some(let rightImage)):
      rightImage
        .image
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: rightImage.size.width,
               height: rightImage.size.height)
    case (.some(let leftImage) ,.none):
      Rectangle()
        .fill(Color.clear)
        .frame(width: leftImage.size.width,
               height: leftImage.size.height)
    case (.none, .none):
      EmptyView()
    }
  }
  
  @ViewBuilder
  private var leftView: some View {
    let leftImage = properties.leftImage
    let rightImage = properties.rightImage
    
    switch (leftImage, rightImage) {
    case (.some(let leftImage), _):
      leftImage
        .image
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: leftImage.size.width,
               height: leftImage.size.height)
        .padding(.leading, 10)
    case (.none, .some(let rightImage)):
      Rectangle()
        .fill(Color.clear)
        .frame(width: rightImage.size.width,
               height: rightImage.size.height)
        .padding(.leading, 10)
    case (.none, .none):
      EmptyView()
    }
  }
  
  @ViewBuilder
  private var rightView: some View {
    let leftImage = properties.leftImage
    let rightImage = properties.rightImage

    switch (leftImage, rightImage) {
    case (_, .some(let image)):
      image
        .image
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: image.size.width,
               height: image.size.height)
        .padding(.trailing, 10)
    case (.some(let leftImage) ,.none):
      Rectangle()
        .fill(Color.clear)
        .frame(width: leftImage.size.width,
               height: leftImage.size.height)
        .padding(.trailing, 10)
    case (.none, .none):
      EmptyView()
    }
  }
  
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
