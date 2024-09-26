//
//  File.swift
//  PovioKit
//
//  Created by Borut Tomazin on 26. 9. 24.
//

#if canImport(Kingfisher)
import UIKit
import Kingfisher

extension UIKit {
  struct PrefetchResult {
    let skipped: Int
    let failed: Int
    let completed: Int
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
  func prefetch(from urls: [URL]) async -> PrefetchResult {
    await withCheckedContinuation { continuation in
      let prefetcher = ImagePrefetcher(urls: urls, options: nil) { skipped, failed, completed in
        let result = PrefetchResult(
          skipped: skipped.count,
          failed: failed.count,
          completed: completed.count
        )
        continuation.resume(with: .success(result))
      }
      prefetcher.start()
    }
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
  func clear(cache: ImageCache = KingfisherManager.shared.cache) {
    cache.clearCache()
  }
}
#endif
