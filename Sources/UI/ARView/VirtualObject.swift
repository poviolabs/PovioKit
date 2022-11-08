//
//  VirtualObject.swift
//  PovioKit
//
//  Created by Ndriqim Nagavci on 01/11/2022.
//  Copyright © 2022 Povio Inc. All rights reserved.
//

import ARKit

public class VirtualObject: SCNNode {
  public var rootNode: SCNNode
  
  /// Alignment of virtual object
  var alignment: ARRaycastQuery.TargetAlignment
  
  /// Rotation of virtual object
  var objectRotation: Float {
    get {
      eulerAngles.y
    }
    
    set {
      eulerAngles.y = newValue
    }
  }
  
  /// The object's corresponding ARAnchor.
  var anchor: ARAnchor?
  
  /// The associated tracked raycast used to place this object.
  /// Tracked raycasting improves hit-testing techniques by repeating the query for a 3D position in succession. ARKit provides an updated position as it refines its understanding of world over time.
  var raycast: ARTrackedRaycast?
  
  var updateAnchor: Bool = false
  
  init(alignment: ARRaycastQuery.TargetAlignment, rootNode: SCNNode) {
    self.alignment = alignment
    self.rootNode = rootNode
    super.init()
    super.addChildNode(rootNode)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func addChildNode(_ child: SCNNode) {
    rootNode.addChildNode(child)
  }
  
  public override var scale: SCNVector3 {
    get {
      rootNode.scale
    }
    
    set {
      rootNode.scale = newValue
    }
  }
}

// MARK: - Public methods
public extension VirtualObject {
  func setRootNode(node: SCNNode) {
    //remove previous nodes if any
    childNodes.forEach({ $0.removeFromParentNode() })
    rootNode = node
    super.addChildNode(rootNode)
  }
  
  func stopTrackedRaycast() {
    raycast?.stopTracking()
    raycast = nil
  }
  
  static func virtualObjectFromNode(_ node: SCNNode) -> VirtualObject? {
    if let virtualObject = node as? VirtualObject {
      return virtualObject
    }
    
    guard let parent = node.parent else { return nil }
    
    return virtualObjectFromNode(parent)
  }
}
