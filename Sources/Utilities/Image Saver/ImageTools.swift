//
//  ImageTools.swift
//  PovioKit
//
//  Created by Borut Tomazin on 13/06/2024.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import UIKit

/// A utility class for performing various image-related operations.
public final class ImageTools: NSObject {
#if canImport(Kingfisher)
  private var prefetcher: ImagePrefetcher?
#endif
  
  override public init() {
    super.init()
  }
}

public extension ImageTools {
  enum ImageError: LocalizedError {
    case invalidPercentage
    case compression
  }
  
  enum ImageFormat {
    case jpeg(compressionRatio: CGFloat)
    case png
  }
  
  /// Saves the given image to the photo library asynchronously.
  ///
  /// This function saves the provided UIImage to the user's photo library. It performs
  /// the operation asynchronously and throws an error if the save operation fails.
  ///
  /// - Parameters:
  ///   - image: The UIImage to be saved to the photo library.
  /// - Example:
  /// ```swift
  /// do {
  ///   let image = UIImage(named: "exampleImage")!
  ///   try await saveImageToPhotoLibrary(image)
  ///   print("Image saved successfully.")
  /// } catch {
  ///   print("Failed to save image: \(error)")
  /// }
  /// ```
  /// - Note: This function should be called from an asynchronous context using `await`.
  /// - Throws: An error if the save operation fails.
  func saveImageToPhotoLibrary(_ image: UIImage) async throws {
    try await withCheckedThrowingContinuation { continuation in
      let continuationWrapper = ContinuationWrapper(continuation: continuation)
      UIImageWriteToSavedPhotosAlbum(
        image,
        self,
        #selector(saveCompleted),
        Unmanaged.passRetained(continuationWrapper).toOpaque()
      )
    }
  }
  
  /// Downsizes the given image to the specified target size asynchronously.
  /// - Parameters:
  ///   - image: The original UIImage to be downsized.
  ///   - targetSize: The desired size to which the image should be downsized.
  /// - Returns: An optional UIImage that is the result of the downsizing operation.
  /// - Example:
  /// ```swift
  /// let image = UIImage(named: "exampleImage")!
  /// let targetSize = CGSize(width: 100, height: 100)
  /// let resizedImage = await downsize(image, to: targetSize)
  /// imageView.image = resizedImage
  /// ```
  /// - Note: This function should be called from an asynchronous context using `await`.
  func downsize(_ image: UIImage, to targetSize: CGSize) async -> UIImage {
    await Task.detached(priority: .high) {
      let originalSize = image.size
      let widthRatio = targetSize.width / originalSize.width
      let heightRatio = targetSize.height / originalSize.height
      let scaleFactor = min(widthRatio, heightRatio)
      let newSize = CGSize(
        width: originalSize.width * scaleFactor,
        height: originalSize.height * scaleFactor
      )
      
      let renderer = UIGraphicsImageRenderer(size: newSize)
      let newImage = renderer.image { _ in
        image.draw(in: CGRect(origin: .zero, size: newSize))
      }
      
      return newImage
    }.value
  }
  
  /// Downsizes the given image by the specified percentage asynchronously.
  /// - Parameters:
  ///   - image: The original UIImage to be downsized.
  ///   - percentage: The percentage by which the image should be downsized. Must be greater than 0 and less than or equal to 100.
  /// - Returns: A UIImage that is the result of the downsizing operation.
  ///
  /// - Example:
  /// ```swift
  /// do {
  ///   let image = UIImage(named: "exampleImage")!
  ///   let percentage: CGFloat = 50.0
  ///   let resizedImage = try await downsize(image, by: percentage)
  ///   imageView.image = resizedImage
  /// } catch {
  ///   print("Failed to downsize image: \(error)")
  /// }
  /// ```
  /// - Note: This function should be called from an asynchronous context using `await`.
  /// - Throws: `ImageError.invalidPercentage` if the percentage is not within the valid range.
  func downsize(_ image: UIImage, by percentage: CGFloat) async throws -> UIImage {
    guard percentage > 0 && percentage <= 100 else {
      throw ImageError.invalidPercentage
    }
    
    return await Task.detached(priority: .high) {
      let scaleFactor = percentage / 100.0
      let newSize = CGSize(
        width: image.size.width * scaleFactor,
        height: image.size.height * scaleFactor
      )
      
      let renderer = UIGraphicsImageRenderer(size: newSize)
      let newImage = renderer.image { _ in
        image.draw(in: CGRect(origin: .zero, size: newSize))
      }
      
      return newImage
    }.value
  }
  
  /// Compresses the given image to the specified format and compression ratio.
  ///
  /// This function compresses the provided UIImage to the specified format (JPEG or PNG).
  /// It returns the compressed image data.
  /// If the compression operation fails, the function throws an error.
  ///
  /// - Parameters:
  ///   - image: The UIImage to be compressed.
  ///   - format: The desired image format (JPEG or PNG).
  /// - Returns: The compressed image data as `Data`.
  /// - Example:
  /// ```swift
  /// do {
  ///   let image = UIImage(named: "exampleImage")!
  ///   let compressedData = try compress(image, format: .jpeg(compressionRatio: 0.8))
  /// } catch {
  ///   print("Failed to compress image: \(error)")
  /// }
  /// ```
  /// - Throws: `ImageError.compression` if the compression operation fails.
  func compress(_ image: UIImage, format: ImageFormat) throws -> Data {
    let compressedImage: Data?
    switch format {
    case .jpeg(let compressionRatio):
      compressedImage = image.jpegData(compressionQuality: compressionRatio)
    case .png:
      compressedImage = image.pngData()
    }
    
    guard let compressedImage else { throw ImageError.compression }
    
    print("Image compressed to:", Double(compressedImage.count) / 1024.0 / 1024.0, "MB")
    return compressedImage
  }
}

#if canImport(Kingfisher)
import Kingfisher

// MARK: - Operations based on Kingfisher lib
public extension ImageTools {
  struct PrefetchResult {
    let skipped: Int
    let failed: Int
    let completed: Int
  }
  
  /// Clears the image cache.
  ///
  /// This function clears the image cache using the specified ImageCache instance.
  /// If no cache instance is provided, it defaults to using the shared cache of the KingfisherManager.
  ///
  /// - Parameters:
  ///   - cache: The ImageCache instance to be cleared. Defaults to `KingfisherManager.shared.cache`.
  ///
  /// - Example:
  /// ```swift
  /// // Clear the default shared cache
  /// clearCache()
  ///
  /// // Clear a specific cache instance
  /// let customCache = ImageCache(name: "customCache")
  /// clearCache(customCache)
  /// ```
  func clearCache(_ cache: ImageCache = KingfisherManager.shared.cache) {
    cache.clearCache()
  }
  
  /// Downloads an image from the given URL asynchronously.
  ///
  /// This function uses the Kingfisher library to download an image from the specified URL.
  /// It performs the download operation asynchronously and returns the downloaded UIImage.
  /// If the download operation fails, the function throws an error.
  ///
  /// - Parameters:
  ///   - url: The URL from which to download the image.
  /// - Returns: The downloaded UIImage.
  ///
  /// - Example:
  /// ```swift
  /// do {
  ///   let url = URL(string: "https://example.com/image.jpg")!
  ///   let downloadedImage = try await download(from: url)
  ///   imageView.image = downloadedImage
  /// } catch {
  ///   print("Failed to download image: \(error)")
  /// }
  /// ```
  ///
  /// - Note: This function should be called from an asynchronous context using `await`.
  /// - Throws: An error if the download operation fails.
  func download(from url: URL) async throws -> UIImage {
    try await withCheckedThrowingContinuation { continuation in
      KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil, downloadTaskUpdated: nil) {
        switch $0 {
        case .success(let result):
          continuation.resume(returning: result.image)
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
  
  /// Prefetches images from the given URLs asynchronously.
  ///
  /// This function uses the Kingfisher library to prefetch images from the specified URLs.
  /// It performs the prefetch operation asynchronously and returns a `PrefetchResult` containing
  /// the counts of skipped, failed, and completed prefetch operations.
  ///
  /// It is usefull when we need to have images ready before we present the UI.
  ///
  /// - Parameters:
  ///   - urls: An array of URLs from which to prefetch images.
  /// - Returns: A `PrefetchResult` containing the counts of skipped, failed, and completed prefetch operations.
  /// - Example:
  /// ```swift
  /// let urls = [
  ///     URL(string: "https://example.com/image1.jpg")!,
  ///     URL(string: "https://example.com/image2.jpg")!
  /// ]
  /// let result = await prefetch(urls: urls)
  /// print("Skipped: \(result.skipped), Failed: \(result.failed), Completed: \(result.completed)")
  /// ```
  /// - Note: This function should be called from an asynchronous context using `await`.
  @discardableResult
  func prefetch(urls: [URL]) async -> PrefetchResult {
    await withCheckedContinuation { continuation in
      prefetcher = ImagePrefetcher(urls: urls, options: nil) { skipped, failed, completed in
        let result = PrefetchResult(
          skipped: skipped.count,
          failed: failed.count,
          completed: completed.count
        )
        continuation.resume(with: .success(result))
      }
      prefetcher?.start()
    }
  }
}
#endif

// MARK: - Private Methods
private extension ImageTools {
  @objc func saveCompleted(
    _ image: UIImage,
    didFinishSavingWithError error: Swift.Error?,
    contextInfo: UnsafeRawPointer
  ) {
    let continuationWrapper = Unmanaged<ContinuationWrapper>.fromOpaque(contextInfo).takeRetainedValue()
    if let error {
      continuationWrapper.continuation.resume(throwing: error)
    } else {
      continuationWrapper.continuation.resume(returning: ())
    }
  }
  
  class ContinuationWrapper {
    let continuation: CheckedContinuation<Void, Error>
    
    init(continuation: CheckedContinuation<Void, Error>) {
      self.continuation = continuation
    }
  }
}