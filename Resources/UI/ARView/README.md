# ARView

A subclass of ARSCNView that supports adding a new `VirtualObject`, Coaching View and Handles following gestures:
  Pan
  Pinch
  Rotate

### ARView Setup:

```swift
lazy var sceneView: ARView = ARView(frame: view.frame)

func setupSceneView() {
  view.addSubview(sceneView)
  sceneView.delegate = self
  sceneView.session.delegate = self
}
```

#### Photo Camera functions

Default coaching goal is horizontalPlane

`func setCoachingGoal(_ goal: ARCoachingOverlayView.Goal)`

Get VirtualObject at point

`func virtualObject(at point: CGPoint) -> VirtualObject?`

Place a new VirtualObject 

`func placeVirtualObject(_ object: VirtualObject)`

Add or update object anchor

`func addOrUpdateAnchor(for object: VirtualObject)`

#### ARViewDelegate

`func arView(_ arView: ARView, didTriggerError: Error?)`

`func arView(_ arView: ARView, placedObject: VirtualObject)`

`func arView(_ arView: ARView, updatedPositionOf object: VirtualObject)`

#### VirtualObject

`init(alignment: ARRaycastQuery.TargetAlignment, rootNode: SCNNode)`
