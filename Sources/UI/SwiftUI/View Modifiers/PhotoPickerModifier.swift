//
//  PhotoPickerModifier.swift
//  PovioKit
//
//  Created by Borut Tomazin on 10/02/2024.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

#if os(iOS)
import SwiftUI

@available(iOS 15.0, *)
public struct PhotoPickerModifier: ViewModifier {
  public typealias VoidHandler = () -> Swift.Void
  public typealias ImageHandler = (UIImage) -> Swift.Void
  
  @Binding var present: Bool
  var canRemove: Bool = true
  var configuration: Configuration = .init()
  var removeHandler: VoidHandler?
  let imageHandler: ImageHandler
  
  @State private var showImageCapture: Bool = false
  @State private var showPhotoLibrary: Bool = false
  
  public func body(content: Content) -> some View {
    content
      .confirmationDialog("", isPresented: $present) {
        Button(configuration.takePhoto) {
          showImageCapture.toggle()
        }
        Button(configuration.chooseFromLibrary) {
          showPhotoLibrary.toggle()
        }
        if canRemove {
          Button(configuration.removePhoto, role: .destructive) {
            removeHandler?()
          }
        }
      }
      .sheet(isPresented: $showPhotoLibrary) {
        PhotoPickerView(sourceType: .photoLibrary) { image in
          imageHandler(image)
        }
        .ignoresSafeArea()
      }
      .fullScreenCover(isPresented: $showImageCapture) {
        PhotoPickerView(sourceType: .camera) { image in
          imageHandler(image)
        }
        .ignoresSafeArea()
      }
  }
  
  struct Configuration {
    var takePhoto: String = "Take a Photo"
    var chooseFromLibrary: String = "Choose from Library"
    var removePhoto: String = "Remove Photo"
  }
}

@available(iOS 15.0, *)
public extension View {
  func photoPicker(
    present: Binding<Bool>,
    canRemove: Bool = true,
    removeHandler: PhotoPickerModifier.VoidHandler?,
    imageHandler: @escaping PhotoPickerModifier.ImageHandler
  ) -> some View {
    modifier(PhotoPickerModifier(
      present: present,
      canRemove: canRemove,
      removeHandler: removeHandler,
      imageHandler: imageHandler
    ))
  }
}

#endif
