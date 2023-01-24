//
//  GenericButton.swift
//  PovioKit
//
//  Created by Arlind Dushi on 3/17/22.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import SwiftUI

private class ActionButtonViewModel: ObservableObject {
  @Published public var title: String = ""
  @Published public var font: Font = .system(size: 18)
  @Published public var textColor: Color = .white
  @Published public var cornerRadius: ActionButton.CornerRadiusType = .custom(0)
  @Published public var backgroundType = ActionButton.Background.plain(.blue)
  @Published public var borderColor: Color = .clear
  @Published public var borderWidth: CGFloat = 0
  @Published public var extraImage: ActionButton.ExtraImage?
}

public struct ActionButton: View {
  @ObservedObject private var properties = ActionButtonViewModel()
  private var actionHandler: (() -> Void)?
  
  public init() {}
  
  public enum Background {
    case plain(Color)
    case linearGradient(LinearGradient)
    case radialGradient(RadialGradient)
    case angularGradient(AngularGradient)
  }
  
  public var body: some View {
    GeometryReader { geo in
      ZStack(alignment: getAlignment(for: properties.extraImage)) {
        ButtonView(size: geo.size, action: buttonAction, properties: properties)
        ExtraImageView(imageAlignment: properties.extraImage, tintColor: properties.textColor, size: geo.size)
      }
    }
  }
  
  public mutating func setAction(action: @escaping () -> Void) {
    actionHandler = action
  }
}

// MARK:- Builder Pattern Methods
public extension ActionButton {
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
  
  func extraImage(_ extraImage: ActionButton.ExtraImage) -> ActionButton {
    self.properties.extraImage = extraImage
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
  
  var extraImage: ActionButton.ExtraImage? {
    get { properties.extraImage }
    set { properties.extraImage = newValue}
  }
}

// MARK: - Public Properties
public extension ActionButton {
  enum ExtraImage {
    case left(Image)
    case center(Image)
    case right(Image)
  }
  
  enum CornerRadiusType {
    case rounded
    case custom(CGFloat)
  }
}

// MARK: - Private Methods
private extension ActionButton {
  func buttonAction() {
    actionHandler?()
  }
  
  func getAlignment(for extraImage: ExtraImage?) -> Alignment {
    switch extraImage {
    case .some(let alignment):
      switch alignment {
      case .right:
        return .trailing
      case .left:
        return .leading
      case .center:
        return .center
      }
    case .none:
      return .trailing
    }
  }
}

// MARK: Views
private extension ActionButton {
  struct ButtonView: View {
    var size: CGSize
    var action: () -> Void
    var properties: ActionButtonViewModel
    
    var body: some View {
      Button(action: {
        action()
      }) {
        Text(properties.title)
          .font(properties.font)
          .padding()
          .frame(width: size.width, height: size.height)
          .foregroundColor(properties.textColor)
          .overlay(
            RoundedRectangle(cornerRadius: getCornerRadius(for: properties.cornerRadius))
              .stroke(properties.borderColor, lineWidth: properties.borderWidth)
          )
      }
      .background(backgroundView)
      .cornerRadius(getCornerRadius(for: properties.cornerRadius))
    }
    
    @ViewBuilder
    var backgroundView: some View {
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
    
    func getCornerRadius(for cornerType: CornerRadiusType) -> CGFloat {
      switch cornerType {
      case .rounded:
        return .infinity
      case .custom(let cornerRadius):
        return cornerRadius
      }
    }
  }
  
  struct ExtraImageView: View {
    var tintColor: Color
    var image: Image
    var height: CGFloat
    var width: CGFloat
    
    init?(imageAlignment: ExtraImage?, tintColor: Color, size: CGSize) {
      switch imageAlignment {
      case .some(let alignment):
        switch alignment {
        case .center(let image), .left(let image), .right(let image):
          self.image = image
        }
        self.tintColor = tintColor
        height = size.height * 0.4
        width = height
      case .none:
        return nil
      }
    }
    
    var body: some View {
      image
        .frame(width: width, height: height)
        .padding()
        .foregroundColor(tintColor)
    }
  }
}

struct PovioButton_Previews: PreviewProvider {
  static var previews: some View {
    ActionButton()
  }
}

