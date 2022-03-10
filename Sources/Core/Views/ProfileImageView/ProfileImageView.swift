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
    public enum Badging {
        case none
        case some(badge: BadgeStyle)
    }
    
    public struct BadgeStyle {
        let image: Image
        let backgroundColor: Color
        let borderColor: Color?
        let borderWidth: CGFloat?
    }
    
    var imageTapped: (() -> Void)?
    @State public var cornerRadius: CGFloat = 0
    @State public var contentMode: ContentMode = .fit
    @State public var borderColor: Color = .clear
    @State public var borderWidth: CGFloat = 0
    @State public var badgeAlignment: Alignment = .bottomTrailing
    @State public var badging: Badging = .some(badge: .init(image: Image(systemName: "scribble"), backgroundColor: .green, borderColor: nil, borderWidth: nil))
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geo in
            ZStack(alignment: badgeAlignment) {
                Image(systemName: "person")
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .frame(width: 100, height: 100)
//                    .frame(width: geo.size.width, height: geo.size.height)
                    .cornerRadius(cornerRadius)
                    .border(borderColor, width: borderWidth)
                    .gesture(TapGesture().onEnded(
                        { imageTapped?() } ))
                getBadge(badingStyle: badging, size: .init(width: 100 / 4, height: 100 / 4))
            }
        }
    }
    
    
    struct Badge: View {
        @State var style: BadgeStyle
        @State var size: CGSize
        
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
    
    private func getBadge(badingStyle: Badging, size: CGSize) -> Badge? {
        switch badingStyle {
        case .none:
            return nil
        case .some(let style):
            return Badge(style: style, size: size)
        }
    }
}

@available(iOS 13, *)
struct ProfileImageView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileImageView()
    }
}

