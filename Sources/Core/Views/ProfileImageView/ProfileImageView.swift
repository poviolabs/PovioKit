//
//  ProfileImageView.swift
//  PovioKit
//
//  Created by Arlind Dushi on 3/9/22.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import SwiftUI

@available(iOS 13, *)
public struct ProfileImageView: View {
    public var imageTapped: (() -> Void)?
    @State public var cornerRadius: CGFloat = 0
    @State public var contentMode: ContentMode = .fit
    @State public var borderColor: Color = .clear
    @State public var borderWidth: CGFloat = 0
    @State public var badgeAlignment: Alignment = .bottomTrailing
    @State public var badging: BadgingMode = .none //.some(badge: .init(image: Image(systemName: "scribble"), backgroundColor: .green, borderColor: nil, borderWidth: nil))
    @State private var urlData: Data?
    @State public var placeHolder = UIImage(systemName: "person")
    
    public enum BadgingMode {
        case none
        case some(badge: BadgeStyle)
    }
    
    public struct BadgeStyle {
        let image: Image
        let backgroundColor: Color
        let borderColor: Color?
        let borderWidth: CGFloat?
    }
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geo in
            ZStack(alignment: badgeAlignment) {
                constructProfileImage(data: urlData, placeHolder: placeHolder!)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .cornerRadius(cornerRadius)
                    .border(borderColor, width: borderWidth)
                    .gesture(TapGesture().onEnded(
                        { imageTapped?() } ))
                Badge(style: badging, size: .init(width: geo.size.width / 4, height: geo.size.height / 4))
            }
        }
    }
    
    struct Badge: View {
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
                        self.urlData = data
                    }
                }
            }.resume()
        case .none:
            DispatchQueue.main.async {
                self.urlData = nil
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

