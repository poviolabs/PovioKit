//
//  PhotoPickerView.swift
//  PovioKit
//
//  Created by Borut Tomazin on 10/02/2024.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import SwiftUI
import UIKit

/// This view should be used in conjuction with `PhotoPicker` view modifier.
struct PhotoPickerView: UIViewControllerRepresentable {
  let sourceType: UIImagePickerController.SourceType
  let onComplete: (UIImage) -> Void
  
  func makeUIViewController(context: Context) -> UIImagePickerController {
    let imagePicker = UIImagePickerController()
    imagePicker.sourceType = sourceType
    imagePicker.delegate = context.coordinator
    return imagePicker
  }
  
  func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { /* --- */ }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(onComplete: onComplete)
  }
  
  final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let onComplete: (UIImage) -> Void
    
    init(onComplete: @escaping (UIImage) -> Void) {
      self.onComplete = onComplete
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
      guard let image = info[.originalImage] as? UIImage else {
        picker.dismiss(animated: true)
        return
      }
      picker.dismiss(animated: true) {
        self.onComplete(image)
      }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      picker.dismiss(animated: true)
    }
  }
}
