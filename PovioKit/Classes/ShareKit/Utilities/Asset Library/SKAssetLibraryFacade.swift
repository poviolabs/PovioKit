//
//  SKAssetLibraryFacade.swift
//  PovioKit
//
//  Created by Toni Kocjan on 37/12/2018.
//  Copyright © 2018 Povio Labs. All rights reserved.
//

import Photos

class SKAssetLibraryFacade {
  enum AssetLibraryError: Error {
    case albumCreationFailed
    case failedToSaveAsset
    case imageLibraryNotAuthorized
    case couldNotObtainUrl
    case wrapped(Error)
  }
  
  let albumName: String
  let libraryProvider: SKAssetLibraryTemplate
  let assetDownloader: SKAssetDownloaderProtocol
  
  init(albumName: String, libraryProvider: SKAssetLibraryTemplate, assetDownloader: SKAssetDownloaderProtocol) {
    self.albumName = albumName
    self.libraryProvider = libraryProvider
    self.assetDownloader = assetDownloader
  }
  
  func saveImage(_ image: UIImage, success: ((URL) -> Void)?, failure: ((AssetLibraryError) -> Void)?) {
    let dispatchSuccess = { (url: URL) in
      DispatchQueue.main.async { success?(url) }
    }
    
    let dispatchFailure = { (error: AssetLibraryError) in
      DispatchQueue.main.async { failure?(error) }
    }
    
    DispatchQueue.global(qos: .utility).async {
      self.libraryProvider.authorizeIfNecessary(success: {
        self.libraryProvider.findOrCreateAlbum(name: self.albumName) { album in
          guard let album = album else {
            dispatchFailure(AssetLibraryError.albumCreationFailed)
            return
          }
          
          self.libraryProvider.saveImage(image: image, album: album) { (asset) in
            guard let asset = asset else {
              dispatchFailure(AssetLibraryError.failedToSaveAsset)
              return
            }
            self.libraryProvider.urlForAsset(asset) { url in
              guard let url = url else {
                dispatchFailure(AssetLibraryError.couldNotObtainUrl)
                return
              }
              dispatchSuccess(url)
            }
          }
        }
      }, failure: {
        dispatchFailure(AssetLibraryError.imageLibraryNotAuthorized)
      })
    }
  }
  
  func saveImage(remoteUrl url: URL, success: ((URL) -> Void)?, failure: ((AssetLibraryError) -> Void)?) {
    assetDownloader.downloadImage(from: url, success: { [weak self] image in
      self?.saveImage(image, success: success, failure: failure)
    }, failure: { error in
      failure?(AssetLibraryError.wrapped(error))
    })
  }
  
  func saveVideo(fromUrl url: URL, success: ((PHAsset, URL?) -> Void)?, failure: ((AssetLibraryError) -> Void)?) {
    let dispatchSuccess = { (asset: PHAsset, url: URL?) in
      DispatchQueue.main.async { success?(asset, url) }
    }
    
    let dispatchFailure = { (error: AssetLibraryError) in
      DispatchQueue.main.async { failure?(error) }
    }
    
    DispatchQueue.global(qos: .utility).async {
      self.libraryProvider.authorizeIfNecessary(success: {
        self.libraryProvider.findOrCreateAlbum(name: self.albumName) { album in
          guard let album = album else {
            dispatchFailure(AssetLibraryError.albumCreationFailed)
            return
          }
          
          self.assetDownloader.downloadVideo(from: url, success: { data in
            do {
              let baseUrl = NSTemporaryDirectory().appending("tmp_file_facelift").appending(".\(url.pathExtension)")
              guard let temporaryFileLocationUrl = URL(string: "file://\(baseUrl)") else {
                dispatchFailure(AssetLibraryError.couldNotObtainUrl)
                return
              }
              try data.write(to: temporaryFileLocationUrl, options: .atomic)
              
              self.libraryProvider.saveVideo(filePath: baseUrl, album: album) { asset in
                guard let asset = asset else {
                  dispatchFailure(AssetLibraryError.failedToSaveAsset)
                  return
                }
                self.libraryProvider.urlForAsset(asset) { url in
                  dispatchSuccess(asset, url)
                }
                
                do { // cleanup
                  try FileManager().removeItem(at: temporaryFileLocationUrl)
                } catch {
                  print("Failed to remove file with error: \(error.localizedDescription)")
                }
              }
            } catch {
              dispatchFailure(AssetLibraryError.wrapped(error))
            }
          }, failure: { error in
            dispatchFailure(AssetLibraryError.wrapped(error))
          })
        }
      }, failure: {
        dispatchFailure(AssetLibraryError.imageLibraryNotAuthorized)
      })
    }
  }
  
  func clearAlbum() {
    libraryProvider.authorizeIfNecessary(success: {
      self.libraryProvider.findOrCreateAlbum(name: self.albumName) { album in
        guard let album = album else { return }
        self.libraryProvider.clearAlbum(album, completion: nil)
      }
    }, failure: nil)
  }
}
