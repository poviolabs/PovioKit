//
//  PhotoCamera.swift
//  PovioKit
//
//  Created by Ndriqim Nagavci on 13/10/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import AVFoundation
import UIKit

public protocol PhotoCameraDelegate: AnyObject {
  func photoCameraDidTakePhoto(_ image: UIImage)
  func photoCameraDidTriggerError(_ error: Camera.Error)
}

public class PhotoCamera: Camera {
  public weak var delegate: PhotoCameraDelegate?
  private let photoOutput = AVCapturePhotoOutput()
  private var deviceInput: AVCaptureDeviceInput?
  
  public init(delegate: PhotoCameraDelegate? = nil) {
    super.init()
    self.delegate = delegate
  }
}

// MARK: - Public Methods
public extension PhotoCamera {
  func prepare() {
    sessionQueue.async {
      do {
        try self.configureComponents()
      } catch {
        
      }
    }
  }
  
  func changeCamera(position: CameraPosition) {
    if cameraPosition == position {
      return
    }
    cameraPosition = position
    prepare()
  }
  
  func takePhoto() {
    let viewPreviewLayerOrientation = previewLayer.connection?.videoOrientation ?? .portrait
    sessionQueue.async {
      guard self.session.isRunning else {
        DispatchQueue.main.async { self.delegate?.photoCameraDidTriggerError(.missingSession) }
        return
      }
      
      let photoSettings = AVCapturePhotoSettings()
      photoSettings.isHighResolutionPhotoEnabled = true
      if self.photoOutput.supportedFlashModes.contains(.auto) {
        photoSettings.flashMode = .auto
      }
      if let photoOutputConnection = self.photoOutput.connection(with: .video) {
        photoOutputConnection.videoOrientation = viewPreviewLayerOrientation
      }
      if let firstAvailablePreviewPhotoPixelFormatTypes = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
        photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: firstAvailablePreviewPhotoPixelFormatTypes]
      }
      
      self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
  }
}

// MARK: - AVCapturePhotoCapture Delegate
extension PhotoCamera: AVCapturePhotoCaptureDelegate {
  public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Swift.Error?) {
    guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else {
      DispatchQueue.main.async { self.delegate?.photoCameraDidTriggerError(.invalidImage) }
      return
    }
    DispatchQueue.main.async { self.delegate?.photoCameraDidTakePhoto(image) }
  }
}

// MARK: - Private Methods
private extension PhotoCamera {
  func configureComponents() throws {
    guard let device = device else { throw Camera.Error.unavailable }
    
    session.beginConfiguration()
    session.sessionPreset = .photo
    
    // remove previous input if any
    if let previousDeviceInput = self.deviceInput {
      session.removeInput(previousDeviceInput)
    }
    
    // prepare input
    guard let deviceInput = try? AVCaptureDeviceInput(device: device), session.canAddInput(deviceInput) else {
      throw Camera.Error.missingInput
    }
    
    self.deviceInput = deviceInput
    session.addInput(deviceInput)
    
    // prepare output
    if !session.outputs.contains(photoOutput) {
      guard session.canAddOutput(photoOutput) else {
        throw Camera.Error.missingOutput
      }
      session.addOutput(photoOutput)
      photoOutput.isHighResolutionCaptureEnabled = true
    }
    
    session.commitConfiguration()
  }
}
