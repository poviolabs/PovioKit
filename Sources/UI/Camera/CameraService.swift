//
//  CameraService.swift
//  PovioKit
//
//  Created by Ndriqim Nagavci on 13/10/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import AVFoundation.AVMediaFormat
import PovioKit

public protocol CameraPermissionProviding  {
  func requestCameraAuthorization() async -> Bool
  func authorizationStatus(forType mediaType: Camera.MediaType) -> Camera.CameraAuthorizationStatus
  func isCameraAvailable(position: Camera.CameraPosition) -> Bool
}

public struct CameraService {
  /* see extension bellow for implementation */
  public init() { }
}

// MARK: - CameraService Protocol
extension CameraService: CameraPermissionProviding {
  /// Check if app is authorized to use camera or not. For the first time this method will ask user for permission.
  public func requestCameraAuthorization() async -> Bool {
    let mediaType = Camera.MediaType.video
    let authStatus = authorizationStatus(forType: mediaType)

    if authStatus == .notDetermined {
      let granted = await AVCaptureDevice.requestAccess(for: mediaType.asAVMediaType)
      return granted
    }
    
    return authStatus == .authorized
  }
  
  /// Returns current camera authorization status
  public func authorizationStatus(forType mediaType: Camera.MediaType) -> Camera.CameraAuthorizationStatus {
    switch AVCaptureDevice.authorizationStatus(for: mediaType.asAVMediaType) {
    case .authorized:
      return .authorized
    case .denied, .restricted:
      return .denied
    case .notDetermined:
      return .notDetermined
    @unknown default:
      Logger.error("Camera device in an unknown state!")
      return .denied
    }
  }
  
  /// Check if camera is available on device
  public func isCameraAvailable(position: Camera.CameraPosition) -> Bool {
    let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: position.asAVCaptureDevicePosition)
    return !session.devices.isEmpty
  }
}
