//
//  SKAssetLibraryProvider.swift
//  PovioKit
//
//  Created by Toni Kocjan on 37/12/2018.
//  Copyright © 2018 Povio Labs. All rights reserved.
//

import Photos

protocol SKAssetLibraryTemplate {
  func authorizeIfNecessary(success: (() -> Void)?, failure: (() -> Void)?)
  func findOrCreateAlbum(name: String, completion: @escaping (PHAssetCollection?) -> Void)
  func createAlbum(name: String, completion: @escaping (PHAssetCollection?) -> Void)
  func saveImage(image: UIImage, album: PHAssetCollection, completion: @escaping (PHAsset?) -> Void)
  func saveVideo(filePath path: String, album: PHAssetCollection, completion: @escaping (PHAsset?) -> Void)
  func urlForAsset(_ asset: PHAsset, completion: @escaping (URL?) -> Void)
  func clearAlbum(_ album: PHAssetCollection, completion: ((Bool) -> Void)?)
}

class SKAssetLibraryProvider: SKAssetLibraryTemplate {
  private enum AssetType: Hashable {
    case image(UIImage)
    case video(String)
  }
  private var assetCache = [AssetType: PHAsset]()
  
  func authorizeIfNecessary(success: (() -> Void)?, failure: (() -> Void)?) {
    guard PHPhotoLibrary.authorizationStatus() != .authorized else {
      success?()
      return
    }
    
    PHPhotoLibrary.requestAuthorization { status in
      status == .authorized ? success?() : failure?()
    }
  }
  
  func findOrCreateAlbum(name: String, completion: @escaping (PHAssetCollection?) -> Void) {
    let fetchOptions = PHFetchOptions()
    fetchOptions.predicate = NSPredicate(format: "title = %@", name)
    guard let photoAlbum = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions).firstObject else {
      return createAlbum(name: name, completion: completion)
    }
    return completion(photoAlbum)
  }
  
  func createAlbum(name: String, completion: @escaping (PHAssetCollection?) -> Void) {
    var albumPlaceholder: PHObjectPlaceholder?
    PHPhotoLibrary.shared().performChanges({
      let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
      albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
    }, completionHandler: { success, error in
      guard success else {
        return completion(nil)
      }
      guard let placeholder = albumPlaceholder else {
        completion(nil)
        return
      }
      guard let album = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil).firstObject else {
        completion(nil)
        return
      }
      completion(album)
    })
  }
  
  func saveImage(image: UIImage, album: PHAssetCollection, completion: @escaping (PHAsset?) -> Void) {
    if let asset = assetCache[AssetType.image(image)] {
      completion(asset)
      return
    }
    
    var placeholder: PHObjectPlaceholder?
    PHPhotoLibrary.shared().performChanges({
      let createAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
      guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: album),
        let photoPlaceholder = createAssetRequest.placeholderForCreatedAsset else { return }
      placeholder = photoPlaceholder
      let fastEnumeration = NSArray(array: [photoPlaceholder] as [PHObjectPlaceholder])
      albumChangeRequest.addAssets(fastEnumeration)
    }, completionHandler: { success, error in
      guard let placeholder = placeholder else {
        completion(nil)
        return
      }
      if success {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
        self.assetCache[AssetType.image(image)] = assets.firstObject
        completion(assets.firstObject)
      } else {
        completion(nil)
      }
    })
  }
  
  func saveVideo(filePath path: String, album: PHAssetCollection, completion: @escaping (PHAsset?) -> Void) {
    if let asset = assetCache[AssetType.video(path)] {
      completion(asset)
      return
    }
    
    var placeholder: PHObjectPlaceholder?
    PHPhotoLibrary.shared().performChanges({
      let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: path))
      guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: album),
        let photoPlaceholder = createAssetRequest?.placeholderForCreatedAsset else { return }
      placeholder = photoPlaceholder
      let fastEnumeration = NSArray(array: [photoPlaceholder] as [PHObjectPlaceholder])
      albumChangeRequest.addAssets(fastEnumeration)
    }, completionHandler: { success, error in
      guard let placeholder = placeholder else {
        completion(nil)
        return
      }
      if success {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
        self.assetCache[AssetType.video(path)] = assets.firstObject
        completion(assets.firstObject)
      } else {
        completion(nil)
      }
    })
  }
  
  func urlForAsset(_ asset: PHAsset, completion: @escaping (URL?) -> Void) {
    asset.requestContentEditingInput(with: PHContentEditingInputRequestOptions()) { input, data in
      switch asset.mediaType {
      case .image:
        completion(input?.fullSizeImageURL)
      case .video:
        completion((input?.audiovisualAsset as? AVURLAsset)?.url)
      default:
        completion(nil)
      }
    }
  }
  
  func clearAlbum(_ album: PHAssetCollection, completion: ((Bool) -> Void)?) {
    PHPhotoLibrary.shared().performChanges({
      let assets = PHAsset.fetchAssets(in: album, options: nil)
      guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: album, assets: assets) else {
        completion?(false)
        return
      }
      albumChangeRequest.removeAssets(assets)
    }, completionHandler: { success, error in
      completion?(success)
    })
  }
}
