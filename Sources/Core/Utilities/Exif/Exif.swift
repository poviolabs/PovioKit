//
//  Exif.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 16/02/2023.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import Foundation
import ImageIO
import PovioKitPromise

/// A wrapper around Image I/O framework APIs that can be used to modify EXIF and other image metadata without recompressing the image data.
public final class Exif {
  private let source: ExifImageSource
  
  public init(source: ExifImageSource) {
    self.source = source
  }
}

// MARK: - Public Methods
public extension Exif {
  /// Read EXIF metadata from the provided image source
  /// - Returns: Dictionary with EXIF values as a Promise or ``ExifError``
  func read() -> Promise<[String: Any]> {
    guard let imageSource = getImageSource() else {
      return .error(ExifError.createImageSource)
    }
    guard let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else {
      return .error(ExifError.getImageProperties)
    }
    return .init(fulfill: imageProperties)
  }
    
  /// Update EXIF metadata with the new values
  ///
  /// Keys for the new values must be part of the [EXIF Dictionary Keys](https://developer.apple.com/documentation/imageio/exif_dictionary_keys)
  /// - Parameter newValue: Dictionary with the new EXIF values
  /// - Returns: New image Data as a Promise or ``ExifError``
  func update(_ newValue: [CFString: String]) -> Promise<Data> {
    guard let imageSource = getImageSource() else {
      return .error(ExifError.createImageSource)
    }
    
    guard let UTI: CFString = CGImageSourceGetType(imageSource) else {
      return .error(ExifError.getImageType)
    }
    
    let imageData: CFMutableData = CFDataCreateMutable(nil, 0)
    guard let destination = CGImageDestinationCreateWithData(imageData as CFMutableData, UTI, 1, nil) else {
      return .error(ExifError.createImageDestination)
    }
    
    var mutableMetadata: CGMutableImageMetadata
    if let imageMetadata = CGImageSourceCopyMetadataAtIndex(imageSource, 0, nil) {
      mutableMetadata = CGImageMetadataCreateMutableCopy(imageMetadata) ?? CGImageMetadataCreateMutable()
    } else {
      mutableMetadata = CGImageMetadataCreateMutable()
    }
    
    for item in newValue {
      CGImageMetadataSetValueMatchingImageProperty(mutableMetadata,
                                                   kCGImagePropertyExifDictionary,
                                                   item.key,
                                                   item.value as CFString)
    }
    
    let options: [String : Any] = [kCGImageDestinationMetadata as String : mutableMetadata,
                                  kCGImageDestinationMergeMetadata as String : true]
    guard CGImageDestinationCopyImageSource(destination, imageSource, options as CFDictionary, nil) else {
      return .error(ExifError.copyImageSource)
    }
    
    return .init(fulfill: imageData as Data)
  }
}

// MARK: - Private Methods
private extension Exif {
  func getImageSource() -> CGImageSource? {
    var imageSource: CGImageSource?
    switch source {
    case .url(let url):
      imageSource = CGImageSourceCreateWithURL(url as CFURL, nil)
    case .data(let data):
      imageSource = CGImageSourceCreateWithData(data as CFData, nil)
    }
    return imageSource
  }
}
