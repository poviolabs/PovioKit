//
//  ARView.swift
//  PovioKit
//
//  Created by Ndriqim Nagavci on 01/11/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import ARKit
import PovioKit

public protocol ARViewDelegate: AnyObject {
  func arView(_ arView: ARView, didTriggerError: Error?)
  func arView(_ arView: ARView, placedObject: VirtualObject)
  func arView(_ arView: ARView, updatedPositionOf object: VirtualObject)
}

public class ARView: ARSCNView {
  public var viewDelegate: ARViewDelegate?
  /// A serial queue used to coordinate adding or removing nodes from the scene.
  public let updateQueue = DispatchQueue(label: "com.poviokit.arview")
}

// MARK: - Private methods
private extension ARView {
  var screenCenter: CGPoint {
    return CGPoint(x: bounds.midX, y: bounds.midY)
  }
  
  func setVirtualObject3DPosition(_ results: [ARRaycastResult], with virtualObject: VirtualObject) {
    guard let result = results.first else {
      fatalError("Unexpected case: the update handler is always supposed to return at least one result.")
    }
    
    self.setTransform(of: virtualObject, with: result)
    
    // If the virtual object is not yet in the scene, add it.
    if virtualObject.parent == nil {
      self.scene.rootNode.addChildNode(virtualObject)
      virtualObject.updateAnchor = true
    }
    
    if virtualObject.updateAnchor {
      virtualObject.updateAnchor = false
      updateQueue.async {
        self.addOrUpdateAnchor(for: virtualObject)
      }
    }
  }
  
  func setTransform(of virtualObject: VirtualObject, with result: ARRaycastResult) {
    virtualObject.simdWorldTransform = result.worldTransform
  }
}

// MARK: - Public methods
public extension ARView {
  func castRay(for query: ARRaycastQuery) -> [ARRaycastResult] {
    return session.raycast(query)
  }
  
  func getRaycastQuery(for alignment: ARRaycastQuery.TargetAlignment = .any) -> ARRaycastQuery? {
    return raycastQuery(from: screenCenter, allowing: .estimatedPlane, alignment: alignment)
  }
  
  func virtualObject(at point: CGPoint) -> VirtualObject? {
    let hitTestOptions: [SCNHitTestOption: Any] = [.boundingBoxOnly: true]
    let hitTestResults = hitTest(point, options: hitTestOptions)
    
    return hitTestResults.lazy.compactMap { result in
      return VirtualObject.virtualObjectFromNode(result.node)
    }.first
  }
  
  func placeVirtualObject(_ object: VirtualObject) {
    guard
      let query = self.getRaycastQuery(for: object.alignment),
      let result = self.castRay(for: query).first else {
      self.viewDelegate?.arView(self, didTriggerError: nil)
      return
    }
    DispatchQueue.global(qos: .userInitiated).async {
      let _ = self.createTrackedRaycastAndSet3DPosition(of: object, from: query, withInitialResult: result)
      self.viewDelegate?.arView(self, placedObject: object)
    }
  }
  
  func addOrUpdateAnchor(for object: VirtualObject) {
    updateQueue.async {
      // If the anchor is not nil, remove it from the session.
      if let anchor = object.anchor {
        self.session.remove(anchor: anchor)
      }
      
      // Create a new anchor with the object's current transform and add it to the session
      let newAnchor = ARAnchor(transform: object.simdWorldTransform)
      object.anchor = newAnchor
      self.session.add(anchor: newAnchor)
    }
  }
  
  func createTrackedRaycastAndSet3DPosition(
    of virtualObject: VirtualObject,
    from query: ARRaycastQuery,
    withInitialResult initialResult: ARRaycastResult? = nil) -> ARTrackedRaycast? {
    if let initialResult = initialResult {
      self.setTransform(of: virtualObject, with: initialResult)
    }
    
    return session.trackedRaycast(query) { (results) in
      self.setVirtualObject3DPosition(results, with: virtualObject)
    }
  }
  
  func createRaycastAndUpdate3DPosition(
    of virtualObject: VirtualObject,
    from query: ARRaycastQuery,
    on interaction: VirtualObjectInteraction) {
      guard let result = self.session.raycast(query).first else {
          return
      }
      
      if virtualObject.alignment == .any && interaction.selectedObject == virtualObject {
        // If an object that's aligned to a surface is being dragged, then
        // smoothen its orientation to avoid visible jumps, and apply only the translation directly.
        virtualObject.simdWorldPosition = result.worldTransform.translation
        
        let previousOrientation = virtualObject.simdWorldTransform.orientation
        let currentOrientation = result.worldTransform.orientation
        virtualObject.simdWorldOrientation = simd_slerp(previousOrientation, currentOrientation, 0.1)
      } else {
        self.setTransform(of: virtualObject, with: result)
      }
      
      self.viewDelegate?.arView(self, updatedPositionOf: virtualObject)
  }
}
