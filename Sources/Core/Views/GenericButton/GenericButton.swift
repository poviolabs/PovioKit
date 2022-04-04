//
//  GenericButton.swift
//  PovioKit
//
//  Created by Arlind Dushi on 3/17/22.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import SwiftUI

@available(iOS 13, *)
public class GenericButtonProperties: ObservableObject {
  @Published public var title: String = ""
  @Published public var font: Font = .system(size: 18)
  @Published public var textColor: Color = .white
  @Published public var cornerRadius: GenericButton.CornerRadiusType = .custom(0)
  @Published public var backgroundType = GenericButton.Background.plain(.blue)
  @Published public var borderColor: Color = .clear
  @Published public var borderWidth: CGFloat = 0
  @Published public var extraImage: GenericButton.ExtraImage?
}

@available(iOS 13, *)
public struct GenericButton: View {
  @ObservedObject public var properties = GenericButtonProperties()
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
        ButtonView(action: buttonAction, properties: properties)
        ExtraImageView(imageAlignment: properties.extraImage, tintColor: properties.textColor, size: geo.size)
      }
    }
  }
  
  public mutating func setAction(action: @escaping () -> Void) {
    actionHandler = action
  }
}

// MARK: - Public Properties
@available(iOS 13, *)
public extension GenericButton {
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
@available(iOS 13, *)
private extension GenericButton {
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
@available(iOS 13, *)
private extension GenericButton {
  struct ButtonView: View {
    var action: () -> Void
    var properties: GenericButtonProperties
    
    var body: some View {
      GeometryReader { geo in
        Button(action: {
          action()
        }) {
          Text(properties.title)
            .font(properties.font)
            .padding()
            .frame(width: geo.size.width, height: geo.size.height)
            .foregroundColor(properties.textColor)
            .overlay(
              RoundedRectangle(cornerRadius: getCornerRadius(for: properties.cornerRadius))
                .stroke(properties.borderColor, lineWidth: properties.borderWidth)
            )
        }
        .background(getBackground())
        .cornerRadius(getCornerRadius(for: properties.cornerRadius))
      }
    }
    
    func getBackground() -> AnyView {
      switch properties.backgroundType {
      case .plain(let backgroundColor):
        return AnyView(backgroundColor)
      case let .linearGradient(gradient):
        return AnyView(gradient)
      case let .angularGradient(gradient):
        return AnyView(gradient)
      case let .radialGradient(gradient):
        return AnyView(gradient)
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

@available(iOS 13, *)
struct PovioButton_Previews: PreviewProvider {
  static var previews: some View {
    GenericButton()
  }
}

