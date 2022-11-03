//
//  ARView.swift
//  PovioKit
//
//  Created by Ndriqim Nagavci on 01/11/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import ARKit

public protocol ARViewDelegate: ARSCNViewDelegate {
  func arView(_ arView: ARView, didTriggerError: Error?)
  func arView(_ arView: ARView, placedObject: VirtualObject)
}

public class ARView: ARSCNView {
  public var viewDelegate: ARViewDelegate?
  /// A serial queue used to coordinate adding or removing nodes from the scene.
  let updateQueue = DispatchQueue(label: "com.poviokit.arview")
  
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
}

// MARK: - Private methods
private extension ARView {
  func castRay(for query: ARRaycastQuery) -> [ARRaycastResult] {
      return session.raycast(query)
  }
  
  func getRaycastQuery(for alignment: ARRaycastQuery.TargetAlignment = .any) -> ARRaycastQuery? {
      return raycastQuery(from: screenCenter, allowing: .estimatedPlane, alignment: alignment)
  }
  
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
    }
  }
  
  func setTransform(of virtualObject: VirtualObject, with result: ARRaycastResult) {
    virtualObject.simdWorldTransform = result.worldTransform
  }
}

// MARK: - Public methods
public extension ARView {
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
}

// MARK: - float4x4 extensions
private extension float4x4 {
  /**
   Treats matrix as a (right-hand column-major convention) transform matrix
   and factors out the translation component of the transform.
  */
  var translation: SIMD3<Float> {
    get {
      let translation = columns.3
      return [translation.x, translation.y, translation.z]
    }
    set(newValue) {
      columns.3 = [newValue.x, newValue.y, newValue.z, columns.3.w]
    }
  }
  
  /**
   Factors out the orientation component of the transform.
  */
  var orientation: simd_quatf {
    return simd_quaternion(self)
  }
  
  /**
   Creates a transform matrix with a uniform scale factor in all directions.
   */
  init(uniformScale scale: Float) {
    self = matrix_identity_float4x4
    columns.0.x = scale
    columns.1.y = scale
    columns.2.z = scale
  }
}

// MARK: - CGPoint extensions
private extension CGPoint {
  /// Extracts the screen space point from a vector returned by SCNView.projectPoint(_:).
  init(_ vector: SCNVector3) {
    self.init(x: CGFloat(vector.x), y: CGFloat(vector.y))
  }

  /// Returns the length of a point when considered as a vector. (Used with gesture recognizers.)
  var length: CGFloat {
    return sqrt(x * x + y * y)
  }
}
