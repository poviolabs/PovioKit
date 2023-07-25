//
//  ProfileImageView.swift
//  PovioKit
//
//  Created by Arlind Dushi on 3/9/22.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import SwiftUI

public struct ProfileImageView: View {
  @ObservedObject private var properties = Properties()
  
  public init() {}
  public init(image: Image) {
    properties.image = image
  }
  
  public var body: some View {
    GeometryReader { geo in
      ZStack(alignment: properties.badging.alignment) {
        ImageView(properties: properties, profileTapped: triggerImageTapClosure)
        BadgeView(style: properties.badging,
                  size: .init(width: geo.size.width / 5, height: geo.size.height / 5),
                  badgeTapped: tiggerBadgeTapClosure)
      }
    }
  }
  
  private func triggerImageTapClosure() { properties.imageTapped?() }
  private func tiggerBadgeTapClosure() { properties.badgeTapped?() }
}

// MARK: - ViewModel
private extension ProfileImageView {
  class Properties: ObservableObject {
    @Published var image: Image?
    @Published var placeholder: Image?
    @Published var initials: String?
    @Published var backgroundType = ProfileImageView.Background.plain(.clear)
    @Published var cornerRadius: ProfileImageView.CornerRadiusType = .circle
    @Published var contentMode: ContentMode = .fit
    @Published var borderColor: Color = .clear
    @Published var borderWidth: CGFloat = 0
    @Published var badging: ProfileImageView.BadgingMode = .none
    @Published var url: URL?
    @Published var imageTapped: (() -> Void)?
    @Published var badgeTapped: (() -> Void)?
  }
}

// MARK: - Views
private extension ProfileImageView {
  struct ImageView: View {
    @ObservedObject var properties: Properties
    var profileTapped: (() -> Void)
    
    private var constructProfileImage: Bool {
      switch (properties.placeholder, properties.url, properties.initials) {
      case ( .some, _, _ ), (_, .some, _), (.none, .none, .none):
        return true
      case (_, _, .some):
        return false
      }
    }
    
    var body: some View {
      GeometryReader { geo in
        if constructProfileImage {
          constructProfileImage(placeholder: properties.image)
            .resolve(from: properties.url, placeholder: properties.placeholder)
            .aspectRatio(contentMode: properties.contentMode)
            .frame(width: geo.size.width, height: geo.size.height)
            .gesture(TapGesture().onEnded({ profileTapped() }))
            .background(backgroundView)
            .overlay(shapeView)
            .cornerRadius(getCornerRadius(for: properties.cornerRadius))
        } else {
          Text(properties.initials ?? "")
            .padding()
            .font(.system(size: geo.size.height > geo.size.width
                          ? geo.size.width * 0.4
                          : geo.size.height * 0.4))
            .frame(width: geo.size.width, height: geo.size.height)
            .gesture(TapGesture().onEnded({ profileTapped() }))
            .background(backgroundView)
            .cornerRadius(getCornerRadius(for: properties.cornerRadius))
          
        }
      }
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
    
    @ViewBuilder
    var shapeView: some View {
      GeometryReader { geo in
        switch (geo.size.height == geo.size.width) {
        case true:
          Circle().stroke(properties.borderColor,
                          lineWidth: properties.borderWidth)
        case false:
          RoundedRectangle(cornerRadius: getCornerRadius(for: properties.cornerRadius))
            .stroke(properties.borderColor, lineWidth: properties.borderWidth)
        }
      }
    }
    
    func constructProfileImage(placeholder: Image?) -> Image {
      if let unwrappedPlaceholder = placeholder {
        return unwrappedPlaceholder
      }
      
      return Image(uiImage: UIImage())
    }
    
    func getCornerRadius(for cornerType: ProfileImageView.CornerRadiusType) -> CGFloat {
      switch cornerType {
      case .circle:
        return .infinity
      case .custom(let cornerRadius):
        return cornerRadius
      }
    }
  }
  
  struct BadgeView: View {
    @State var style: Badge
    @State var size: CGSize
    var badgeTapped: (() -> Void)

    
    init?(style: BadgingMode,
          size: CGSize,
          badgeTapped: @escaping () -> ()) {
      self.badgeTapped = badgeTapped
      
      switch style {
      case .none:
        return nil
      case .some(let badge):
        self.style = badge
        self.size = size
      }
    }
    
    var body: some View {
      style.image
        .frame(width: size.width, height: size.height)
        .aspectRatio(contentMode: style.contentMode)
        .foregroundColor(style.tintColor)
        .padding(.all, 5)
        .background(style.backgroundColor)
        .clipShape(Circle())
        .overlay(Circle().stroke(
          (style.borderColor != nil) ? style.borderColor! : Color.white,
          lineWidth: (style.borderWidth != nil) ? style.borderWidth! : 2)
        )
        .gesture(TapGesture().onEnded({ badgeTapped() }))
    }
  }
}

// MARK: - Public Properties
public extension ProfileImageView {
  struct Badge {
    let image: Image
    let contentMode: ContentMode
    let backgroundColor: Color
    let tintColor: Color
    let alignment: Alignment
    let borderColor: Color?
    let borderWidth: CGFloat?
    
    public init(image: Image,
                contentMode: ContentMode = .fit,
                tintColor: Color = .white,
                backgroundColor: Color,
                alignment: Alignment,
                borderColor: Color? = nil,
                borderWidth: CGFloat? = nil) {
      self.image = image
      self.contentMode = contentMode
      self.tintColor = tintColor
      self.backgroundColor = backgroundColor
      self.alignment = alignment
      self.borderColor = borderColor
      self.borderWidth = borderWidth
    }
  }
  
  enum BadgingMode {
    case none
    case some(badge: Badge)
    
    var alignment: Alignment {
      switch self {
      case .none:
        return .bottomTrailing
      case .some(badge: let badge):
        return badge.alignment
      }
    }
  }
  
  enum Background {
    case plain(Color)
    case linearGradient(LinearGradient)
    case radialGradient(RadialGradient)
    case angularGradient(AngularGradient)
  }
  
  enum CornerRadiusType {
    case circle
    case custom(CGFloat)
  }
}

// MARK: - Builder Pattern Methods
public extension ProfileImageView {
  func image(_ image: Image) -> Self {
    properties.image = image
    return self
  }
  
  func set(_ initials: String) -> Self {
    properties.initials = String(initials.safePrefix(2)).uppercased()
    return self
  }
  
  func backgroundType(_ backgroundType: Background) -> Self {
    properties.backgroundType = backgroundType
    return self
  }
  
  func cornerRadius(_ cornerRadius: CornerRadiusType) -> Self {
    properties.cornerRadius = cornerRadius
    return self
  }
  
  func contentMode(_ contentMode: ContentMode) -> Self {
    properties.contentMode = contentMode
    return self
  }
  
  func borderColor(_ borderColor: Color) -> Self {
    properties.borderColor = borderColor
    return self
  }
  
  func borderWidth(_ borderWidth: CGFloat) -> Self {
    properties.borderWidth = borderWidth
    return self
  }
  
  func badging(_ badging: BadgingMode) -> Self {
    properties.badging = badging
    return self
  }
  
  func url(_ url: URL?, placeholder: Image? = nil) -> Self {
    properties.url = url
    properties.placeholder = placeholder
    return self
  }
  
  func onBadgeTap(_ badgeTapped: @escaping (() -> Void)) -> Self {
    self.properties.badgeTapped = badgeTapped
    return self
  }
  
  func onProfileTap(_ imageTapped: @escaping (() -> Void)) -> Self {
    self.properties.imageTapped = imageTapped
    return self
  }
}

// MARK: - Access to properties from UIKit
public extension ProfileImageView {
  var image: Image? {
    get { properties.image }
    set { properties.image = newValue}
  }
  
  var backgroundType: Background {
    get { properties.backgroundType }
    set { properties.backgroundType = newValue }
  }
  
  var cornerRadius: CornerRadiusType {
    get { properties.cornerRadius }
    set { properties.cornerRadius = newValue }
  }
  
  var contentMode: ContentMode {
    get { properties.contentMode }
    set { properties.contentMode = newValue }
  }
  
  var borderColor: Color {
    get { properties.borderColor }
    set { properties.borderColor = newValue }
  }
  
  var borderWidth: CGFloat {
    get { properties.borderWidth }
    set { properties.borderWidth = newValue }
  }
  
  var badging: BadgingMode {
    get { properties.badging }
    set { properties.badging = newValue }
  }
  
  func set(_ url: URL?, placeholder: Image? = nil) {
    properties.url = url
    properties.placeholder = placeholder
  }
  
  func set(_ initials: String) {
    properties.initials = String(initials.safePrefix(2)).uppercased()
  }
  
  func addActionOnProfileTap(_ action: @escaping () -> Void) {
    properties.imageTapped = action
  }
  
  func addActionOnBadgeTap(_ action: @escaping () -> Void) {
    properties.badgeTapped = action
  }
}

struct ProfileImageView_Previews: PreviewProvider {
  static var previews: some View {
    ProfileImageView()
  }
}

