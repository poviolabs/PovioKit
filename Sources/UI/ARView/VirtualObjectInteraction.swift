//
//  VirtualObjectInteraction.swift
//  PovioKit
//
//  Created by Ndriqim Nagavci on 8/11/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import ARKit
import UIKit
import PovioKit

public class VirtualObjectInteraction: NSObject {
  public var selectedObject: VirtualObject?
  private var initialObjectScale: Float = 1
  private var currentTrackingPosition: CGPoint?
  
  private let sceneView: ARView
  
  public init(sceneView: ARView) {
    self.sceneView = sceneView
    super.init()
    
    createGestureRecognizers()
  }
}

// MARK: Private methods
private extension VirtualObjectInteraction {
  func createGestureRecognizers() {
    createTapGesture()
    createPanGesture()
    createPinchGesture()
    createRotationGesture()
  }
  
  func createTapGesture() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
    sceneView.addGestureRecognizer(tapGesture)
  }
  
  func createPanGesture() {
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
    panGesture.delegate = self
    sceneView.addGestureRecognizer(panGesture)
  }
  
  func createPinchGesture() {
    let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
    pinchGesture.delegate = self
    sceneView.addGestureRecognizer(pinchGesture)
  }
  
  func createRotationGesture() {
    let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotationGesture(_:)))
    rotationGesture.delegate = self
    sceneView.addGestureRecognizer(rotationGesture)
  }
  
  @objc func handleTapGesture(_ gesture: UITapGestureRecognizer) {
    let touchLocation = gesture.location(in: sceneView)
    
    if let tappedObject = sceneView.virtualObject(at: touchLocation) {
      selectedObject = tappedObject
    } else if let object = selectedObject {
      setDown(object, basedOn: touchLocation)
    }
  }
  
  @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
    switch gesture.state {
    case .began:
      guard let object = objectInteracting(with: gesture) else { return }
      selectedObject = object
    case .changed:
      guard let selectedObject else { return }
      translate(selectedObject, basedOn: updatedTrackingPosition(for: selectedObject, from: gesture))
      gesture.setTranslation(.zero, in: sceneView)
    default:
      break
    }
  }
  
  @objc func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
    switch gesture.state {
    case .began:
      guard let object = objectInteracting(with: gesture) else { return }
      selectedObject = object
      initialObjectScale = object.scale.x
    case .changed:
      guard let selectedObject else { return }
      let scale = Float(gesture.scale)
      selectedObject.scale = SCNVector3(initialObjectScale * scale, initialObjectScale * scale, initialObjectScale * scale)
    default:
      break
    }
  }
  
  @objc func handleRotationGesture(_ gesture: UIRotationGestureRecognizer) {
    guard let selectedObject, gesture.state == .changed else { return }
    selectedObject.objectRotation -= Float(gesture.rotation)
    gesture.rotation = 0
  }
  
  func objectInteracting(with gesture: UIGestureRecognizer) -> VirtualObject? {
    for index in 0..<gesture.numberOfTouches {
      let touchLocation = gesture.location(ofTouch: index, in: sceneView)
      
      // Look for an object directly under the `touchLocation`.
      if let object = sceneView.virtualObject(at: touchLocation) {
        return object
      }
    }
    
    // As a last resort look for an object under the center of the touches.
    if let center = gesture.center(in: sceneView) {
      return sceneView.virtualObject(at: center)
    }
    
    return nil
  }
  
  func translate(_ object: VirtualObject, basedOn screenPos: CGPoint) {
    object.stopTrackedRaycast()
    
    // Update the object by using a one-time position request.
    if let query = sceneView.raycastQuery(from: screenPos, allowing: .estimatedPlane, alignment: object.alignment) {
      sceneView.createRaycastAndUpdate3DPosition(of: object, from: query, on: self)
    }
  }
  
  func setDown(_ object: VirtualObject, basedOn screenPos: CGPoint) {
    object.stopTrackedRaycast()
    
    // Prepare to update the object's anchor to the current location.
    object.updateAnchor = true
    
    // Attempt to create a new tracked raycast from the current location.
    if let query = sceneView.raycastQuery(from: screenPos, allowing: .estimatedPlane, alignment: object.alignment),
      let raycast = sceneView.createTrackedRaycastAndSet3DPosition(of: object, from: query) {
      object.raycast = raycast
    } else {
      // If the tracked raycast did not succeed, simply update the anchor to the object's current position.
      object.updateAnchor = false
      sceneView.updateQueue.async {
        self.sceneView.addOrUpdateAnchor(for: object)
      }
    }
  }
  
  func updatedTrackingPosition(for object: VirtualObject, from gesture: UIPanGestureRecognizer) -> CGPoint {
    let translation = gesture.translation(in: sceneView)
    
    let currentPosition = currentTrackingPosition ?? CGPoint(sceneView.projectPoint(object.position))
    let updatedPosition = CGPoint(x: currentPosition.x + translation.x, y: currentPosition.y + translation.y)
    currentTrackingPosition = updatedPosition
    return updatedPosition
  }
}

// MARK: - GestureRecognizerDelegate
extension VirtualObjectInteraction: UIGestureRecognizerDelegate {
  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    true
  }
}
