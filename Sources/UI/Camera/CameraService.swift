//
//  CameraService.swift
//  PovioKit
//
//  Created by Ndriqim Nagavci on 13/10/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import AVFoundation.AVMediaFormat
import PovioKit

protocol CameraServiceProtocol: AnyObject {
  func requestCameraAuthorization(_ completion: ((Bool) -> Void)?)
  func authorizationStatus(forType mediaType: AVMediaType) -> AVAuthorizationStatus
  func isCameraAvailable(position: AVCaptureDevice.Position) -> Bool
}

class CameraService { /* see extension bellow for implementation */ }

// MARK: - CameraService Protocol
extension CameraService: CameraServiceProtocol {
  /// Check if app is authorized to use camera or not. For the first time this method will ask user for permission.
  func requestCameraAuthorization(_ completion: ((Bool) -> Void)?) {
    let mediaType = AVMediaType.video
    let authStatus = authorizationStatus(forType: mediaType)
    
    switch authStatus {
    case .authorized:
      completion?(true)
    case .denied, .restricted:
      completion?(false)
    case .notDetermined:
      // prompt user for camera permission only for the first time
      AVCaptureDevice.requestAccess(for: mediaType) { granted in
        DispatchQueue.main.async {
          completion?(granted)
        }
      }
    @unknown default:
      Logger.debug("Audio device in an unknown state ...")
    }
  }
  
  /// Returns current camera authorization status
  func authorizationStatus(forType mediaType: AVMediaType) -> AVAuthorizationStatus {
    AVCaptureDevice.authorizationStatus(for: mediaType)
  }
  
  /// Check if camera is available on device
  func isCameraAvailable(position: AVCaptureDevice.Position) -> Bool {
    let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: position)
    return !session.devices.isEmpty
  }
}
