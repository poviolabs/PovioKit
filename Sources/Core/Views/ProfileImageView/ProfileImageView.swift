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
    @Published public var placeHolder = UIImage(systemName: "person")
    @Published public var badging: ProfileImageView.BadgingMode = .none //.some(badge: .init(image: Image(systemName: "scribble"), backgroundColor: .green, borderColor: nil, borderWidth: nil))
    @Published public var cornerRadius: CGFloat = 0
    @Published public var contentMode: ContentMode = .fit
    @Published public var borderColor: Color = .clear
    @Published public var borderWidth: CGFloat = 0
    @Published public var badgeAlignment: Alignment = .bottomTrailing
    @Published var urlData: Data?
}

@available(iOS 13, *)
public struct ProfileImageView: View {
    public var imageTapped: (() -> Void)?
    @ObservedObject public var properties = ProfileImageProperties()
    
    public struct BadgeStyle {
        let image: Image
        let backgroundColor: Color
        let borderColor: Color?
        let borderWidth: CGFloat?
    }
    
    public enum BadgingMode {
        case none
        case some(badge: BadgeStyle)
    }
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geo in
            ZStack(alignment: properties.badgeAlignment) {
                constructProfileImage(data: properties.urlData, placeHolder: properties.placeHolder!)
                    .resizable()
                    .aspectRatio(contentMode: properties.contentMode)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .cornerRadius(properties.cornerRadius)
                    .border(properties.borderColor, width: properties.borderWidth)
                    .gesture(TapGesture().onEnded(
                        { imageTapped?() } ))
                Badge(style: properties.badging, size: .init(width: geo.size.width / 4, height: geo.size.height / 4))
            }
        }
    }
    
    private struct Badge: View {
        @State var style: BadgeStyle
        @State var size: CGSize
        
        init?(style: BadgingMode, size: CGSize) {
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
                .overlay(Circle().stroke(
                    (style.borderColor != nil) ? style.borderColor! : Color.white,
                    lineWidth: (style.borderWidth != nil) ? style.borderWidth! : 2)
                )
        }
    }
    
    private func constructProfileImage(data: Data?, placeHolder: UIImage) -> Image {
        switch data {
        case .some(let data):
            if let createdImage =  UIImage(data: data) {
                return Image(uiImage: createdImage)
            } else {
                return Image(uiImage: placeHolder)
            }
        case .none:
            return Image(uiImage: placeHolder)
        }
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

