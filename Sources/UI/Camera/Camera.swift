//
//  Camera.swift
//  PovioKit
//
//  Created by Ndriqim Nagavci on 13/10/2022.
//  Copyright © 2023 Povio Inc. All rights reserved.
//

import AVFoundation
import PovioKitCore

public class Camera: NSObject {
  var device: AVCaptureDevice? {
    switch cameraPosition {
    case .back:
      return isCameraAvailable(position: .back) ? AVCaptureDevice.default(for: .video) : nil
    case .front:
      return isCameraAvailable(position: .front) ? AVCaptureDevice.default(deviceType, for: .video, position: .front) : nil
    }
  }
  let session = AVCaptureSession()
  // Communicate with the session and other session objects on this queue.
  let sessionQueue = DispatchQueue(label: "com.poviokit.camera")
  public lazy var previewLayer: AVCaptureVideoPreviewLayer = {
    let previewLayer = AVCaptureVideoPreviewLayer(session: session)
    previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    
    return previewLayer
  }()
  public let cameraService: CameraService
  public var deviceType: AVCaptureDevice.DeviceType = .builtInWideAngleCamera
  var cameraPosition: CameraPosition = .back
  
  init(with cameraService: CameraService = CameraService()) {
    self.cameraService = cameraService
    super.init()
  }
  
  deinit {
    stopSession()
  }
}

// MARK: - Public Methods
public extension Camera {
  var isTorchAvailable: Bool {
    device.map { $0.hasTorch && $0.isTorchAvailable } ?? false
  }
  
  func requestAuthorizationStatus() async -> Bool {
    await cameraService.requestCameraAuthorization()
  }
  
  func startSession() {
    sessionQueue.async {
      guard !self.session.isRunning else { return }
      self.session.startRunning()
    }
  }
  
  func stopSession() {
    sessionQueue.async {
      guard self.session.isRunning else { return }
      self.session.stopRunning()
    }
    try? setTorch(on: false) // just in case but flashlight is automatically turned off when session is stopped
  }
  
  func toggleTorch() throws {
    try setTorch(on: !(device?.isTorchActive ?? true))
  }
  
  func setZoom(_ zoomFactor: CGFloat,
               animated: Bool = true,
               rate: Float = 5) throws {
    guard let device else { return }
    let clampedZoomFactor = max(device.minAvailableVideoZoomFactor, min(zoomFactor, device.maxAvailableVideoZoomFactor))
    try device.lockForConfiguration()
    if animated {
      device.ramp(toVideoZoomFactor: clampedZoomFactor, withRate: rate)
    } else {
      device.videoZoomFactor = clampedZoomFactor
    }
    device.unlockForConfiguration()
  }
}

// MARK: - Private Methods
private extension Camera {
  /// Check if camera is available on device
  func isCameraAvailable(position: Camera.CameraPosition) -> Bool {
    !AVCaptureDevice
      .DiscoverySession(
        deviceTypes: [deviceType],
        mediaType: .video,
        position: position.asAVCaptureDevicePosition)
      .devices
      .isEmpty
  }
  
  func setTorch(on: Bool) throws {
    guard let device = device, device.hasTorch, device.isTorchAvailable else { return }
    try device.lockForConfiguration()
    switch on {
    case true:
      try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
    case false:
      device.torchMode = .off
    }
    device.unlockForConfiguration()
  }
}
