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
    cameraService.isCameraAvailable ? AVCaptureDevice.default(for: .video) : nil
  }
  let session = AVCaptureSession()
  public lazy var previewLayer = AVCaptureVideoPreviewLayer(session: session)
  private let cameraService: CameraServiceProtocol
  
  init(with cameraService: CameraServiceProtocol = CameraService()) {
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
  enum CameraAuthorizationStatus {
    case authorized
    case denied
  }
  
  enum Error: Swift.Error {
    case unavailable
    case missingSession
    case missingInput
    case missingOutput
    case invalidImage
  }
  
  var isTorchAvailable: Bool {
    device.map { $0.hasTorch && $0.isTorchAvailable } ?? false
  }
  
  @available(iOS 13.0.0, *)
  func getAuthorizationStatus() async -> CameraAuthorizationStatus {
    await withCheckedContinuation({ continuation in
      cameraService.requestCameraAuthorization { authorized in
        continuation.resume(returning: authorized ? .authorized : .denied)
      }
    })
  }
  
  func startSession() {
    guard !session.isRunning else { return }
    DispatchQueue.global(qos: .userInitiated).async {
      self.session.startRunning()
    }
  }
  
  func stopSession() {
    guard session.isRunning else { return }
    session.stopRunning()
    setTorch(on: false) // just in case but flashlight is automatically turned off when session is stopped
  }
  
  func toggleTorch() {
    setTorch(on: !(device?.isTorchActive ?? true))
  }
}

// MARK: - Private Methods
private extension Camera {
  func configureComponents() {
    guard cameraService.isCameraAvailable else { return }
    previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
  }
  
  func setTorch(on: Bool) {
    guard let device = device, device.hasTorch, device.isTorchAvailable else { return }
    do {
      try device.lockForConfiguration()
      switch on {
      case true:
        try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
      case false:
        device.torchMode = .off
      }
      device.unlockForConfiguration()
    } catch {
      Logger.debug("Could not lock the camera device")
    }
  }
}
