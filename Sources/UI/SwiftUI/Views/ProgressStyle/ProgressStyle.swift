//
//  ProgressStyle.swift
//  PovioKit
//
//  Created by Borut Tomazin on 02/03/2024.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import SwiftUI

@available(iOS 15.0, *)
public struct ProgressStyle: ProgressViewStyle {
  var trackColor: Color = .gray
  var progressColor: Color = .black
  var cornerRadius: CGFloat = 8
  
  public func makeBody(configuration: Configuration) -> some View {
    let completed = configuration.fractionCompleted ?? 0
    return GeometryReader { geo in
      ZStack(alignment: .leading) {
        RoundedRectangle(cornerRadius: cornerRadius)
          .fill(trackColor)
        RoundedRectangle(cornerRadius: cornerRadius)
          .fill(progressColor)
          .frame(width: completed * geo.size.width)
      }
    }
  }
}

@available(iOS 15.0, *)
#Preview {
  ProgressView(value: 0.5)
    .progressViewStyle(ProgressStyle())
    .frame(height: 5)
    .padding(.horizontal, 20)
}
