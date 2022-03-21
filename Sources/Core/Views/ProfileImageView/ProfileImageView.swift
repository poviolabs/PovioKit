//
//  ProfileImageView.swift
//  PovioKit
//
//  Created by Arlind Dushi on 3/9/22.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import SwiftUI

@available(iOS 13, *)
public class ProfileImageProperties: ObservableObject {
  @Published public var placeholder: Image?
  @Published public var backgroundType = ProfileImageView.Background.plain(.clear)
  @Published public var cornerRadius: ProfileImageView.CornerRadiusType = .circle
  @Published public var contentMode: ContentMode = .fit
  @Published public var borderColor: Color = .clear
  @Published public var borderWidth: CGFloat = 0
  @Published public var badging: ProfileImageView.BadgingMode = .none
  @Published var urlData: Data?
}

@available(iOS 13, *)
public struct ProfileImageView: View {
  public var imageTapped = Delegated<Void, Void>()
  public var badgeTapped = Delegated<Void, Void>()
  @ObservedObject public var properties = ProfileImageProperties()
  
  public init() {}
  
  public var body: some View {
    GeometryReader { geo in
      ZStack(alignment: properties.badging.alignment) {
        ImageView(properties: properties, profileTapped: triggerImageTapClosure)
        BadgeView(style: properties.badging, size: .init(width: geo.size.width / 3.5, height: geo.size.height / 3.5), badgeTapped: tiggerBadgeTapClosure)
      }
    }
  }
  
  private func triggerImageTapClosure() { imageTapped() }
  private func tiggerBadgeTapClosure() { badgeTapped() }
}

@available(iOS 13, *)
private extension ProfileImageView {
  struct ImageView: View {
    @ObservedObject var properties: ProfileImageProperties
    var profileTapped: (() -> Void)
    var optionalPlaceHolder: UIImage?
    
    var body: some View {
      GeometryReader { geo in
        constructProfileImage(data: properties.urlData, placeholder: properties.placeholder)
          .resizable()
          .aspectRatio(contentMode: properties.contentMode)
          .frame(width: geo.size.width, height: geo.size.height)
          .gesture(TapGesture().onEnded({ profileTapped() }))
          .background(getBackground())
          .overlay(getShape(for: geo.size))
          .cornerRadius(getCornerRadius(for: properties.cornerRadius))
      }
    }
    
    func constructProfileImage(data: Data?, placeholder: Image?) -> Image {
      if let unrappedData = data, let createdImage = UIImage(data: unrappedData) {
        return Image(uiImage: createdImage)
      }
      
      if let unwrappedPlaceholder = placeholder {
        return unwrappedPlaceholder
      }
      
      return Image(uiImage: UIImage())
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
    
    func getCornerRadius(for cornerType: ProfileImageView.CornerRadiusType) -> CGFloat {
       switch cornerType {
       case .circle:
         return .infinity
       case .custom(let cornerRadius):
         return cornerRadius
       }
     }
    
    func getShape(for size: CGSize) -> AnyView {
      let height = size.height
      let width = size.width
      
      switch (height == width) {
      case true:
        return AnyView(Circle().stroke(properties.borderColor,
                                       lineWidth: properties.borderWidth))
      case false:
        return AnyView(RoundedRectangle(cornerRadius: getCornerRadius(for: properties.cornerRadius))
          .stroke(properties.borderColor, lineWidth: properties.borderWidth))
      }
    }
  }
  
  struct BadgeView: View {
    @State var style: Badge
    @State var size: CGSize
    var badgeTapped: (() -> Void)

    
    init?(style: BadgingMode, size: CGSize, badgeTapped: @escaping () -> ()) {
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
        .foregroundColor(.white)
        .frame(width: size.width, height: size.height)
        .background(style.backgroundColor)
        .clipShape(Circle())
        .gesture(TapGesture().onEnded({ badgeTapped() }))
        .overlay(Circle().stroke(
          (style.borderColor != nil) ? style.borderColor! : Color.white,
          lineWidth: (style.borderWidth != nil) ? style.borderWidth! : 2)
        )
    }
  }
}


// MARK: - Public Properties
@available(iOS 13, *)
public extension ProfileImageView {
  struct Badge {
    let image: Image
    let backgroundColor: Color
    let borderColor: Color?
    let borderWidth: CGFloat?
    let alignment: Alignment
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

// MARK: - Public Methods
@available(iOS 13, *)
public extension ProfileImageView {
  func set(_ url: URL?) {
    switch url {
    case .some(let url):
      URLSession.shared.dataTask(with: url) { data, response, error in
        if let data = data {
          DispatchQueue.main.async {
            properties.urlData = data
          }
        }
      }.resume()
    case .none:
      DispatchQueue.main.async {
        properties.urlData = nil
      }
    }
  }
}

@available(iOS 13, *)
struct ProfileImageView_Previews: PreviewProvider {
  static var previews: some View {
    ProfileImageView()
  }
}

