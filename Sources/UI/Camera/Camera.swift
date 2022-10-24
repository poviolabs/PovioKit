//
//  Camera.swift
//  PovioKit
//
//  Created by Ndriqim Nagavci on 13/10/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import AVFoundation
import PovioKit

public class Camera: NSObject {
  var device: AVCaptureDevice? {
    switch cameraPosition {
    case .back:
      return cameraService.isCameraAvailable(position: .back) ? AVCaptureDevice.default(for: .video) : nil
    case .front:
      return cameraService.isCameraAvailable(position: .front) ? AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) : nil
    }
  }
  let session = AVCaptureSession()
  // Communicate with the session and other session objects on this queue.
  let sessionQueue = DispatchQueue(label: "com.poviokit.camera")
  public lazy var previewLayer = AVCaptureVideoPreviewLayer(session: session)
  public let cameraService: CameraPermissionProviding
  var cameraPosition: CameraPosition = .back
  
  init(with cameraService: CameraPermissionProviding = CameraService()) {
    self.cameraService = cameraService
    super.init()
    configureComponents()
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
}

// MARK: - Private Methods
private extension Camera {
  func configureComponents() {
    guard cameraService.isCameraAvailable(position: cameraPosition) else { return }
    previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
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
