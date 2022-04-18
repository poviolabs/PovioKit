//
//  ImageSource.swift
//  PovioKit
//
//  Created by Toni Kocjan on 26/07/2020.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import UIKit

public enum ImageSource {
  case image(UIImage)
  case remote(URL, placeholder: UIImage?)
}

public extension ImageSource {
  static func remote(_ url: URL) -> ImageSource {
    .remote(url, placeholder: nil)
  }
  
  static func remote(_ urlString: String, placeholder: UIImage? = nil) -> ImageSource? {
    URL(string: urlString).map { ImageSource.remote($0, placeholder: placeholder) }
  }
  
  static func image(_ image: UIImage?) -> ImageSource {
    .image(image ?? UIImage())
  }
  
  static func image(_ named: String) -> ImageSource {
    .image(UIImage(named: named))
  }
}

extension ImageSource: Equatable {}

#if canImport(Kingfisher)
import Kingfisher

public extension UIImageView {
  func resolve(with source: ImageSource) {
    image = nil
    resolve(with: source, completion: nil)
  }
  
  func resolve(with source: ImageSource, completion: (() -> Void)?) {
    image = nil
    switch source {
    case .image(let image):
      self.image = image
      completion?()
    case let .remote(url, placeholder):
      kf.setImage(with: ImageResource(downloadURL: url),
                  placeholder: placeholder,
                  options: nil,
                  progressBlock: nil,
                  completionHandler: { _ = $0.map { _ in completion?() } })
    }
  }
}

public extension UIButton {
  func resolve(with source: ImageSource) {
    resolve(with: source, placeholder: nil)
  }
  
  func resolve(with source: ImageSource, placeholder: UIImage?) {
    switch source {
    case .image(let image):
      self.setImage(image, for: .normal)
    case let .remote(url, placeholder):
      kf.setImage(with: ImageResource(downloadURL: url), for: .normal, placeholder: placeholder)
    }
  }
}
#endif
