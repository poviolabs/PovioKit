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
      let granted = await AVCaptureDevice.requestAccess(for: mediaTypeMapper(mediaType))
      return granted
    }
    
    return authStatus == .authorized ? true : false
  }
  
  /// Returns current camera authorization status
  public func authorizationStatus(forType mediaType: Camera.MediaType) -> Camera.CameraAuthorizationStatus {
    switch AVCaptureDevice.authorizationStatus(for: mediaTypeMapper(mediaType)) {
    case .authorized:
      return .authorized
    case .denied, .restricted:
      return .denied
    case .notDetermined:
      return .notDetermined
    @unknown default:
      Logger.debug("Audio device in an unknown state ...")
      return .denied
    }
    
  }
  
  /// Check if camera is available on device
  public func isCameraAvailable(position: Camera.CameraPosition) -> Bool {
    let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: positionMapper(position))
    return !session.devices.isEmpty
  }
}

// MARK: - Private methods
private extension CameraService {
  func positionMapper(_ position: Camera.CameraPosition) -> AVCaptureDevice.Position {
    switch position {
    case .back:
      return .back
    case .front:
      return .front
    }
  }
  
  func mediaTypeMapper(_ type: Camera.MediaType) -> AVMediaType {
    switch type {
    case .video:
      return .video
    case .audio:
      return .audio
    }
  }
}
