# Camera

A UI component that simplifies handling with camera. `PhotoCamera` & `QRCodeScanner`.

### PhotoCamera Example:
```swift
let camera = PhotoCamera()
func prepareCamera() {
  do {
    try await camera.prepare()
  } catch {
    // error handling
  }

  // add previewLayer to any view
  view.layer.addSublayer(camera.previewLayer)
  camera.previewLayer.frame = self.view.bounds
    
  // set camera delegate
  camera.delegate = self
    
  // request authorization status
  let granted = await camera.requestAuthorizationStatus()
    
  switch granted {
  case true:
    self.camera.startSession()
  case false:
    // handle denied status
    break
  }
}
```
#### Photo Camera functions
`func takePhoto()`

We can also switch from front facing to back camera:

`func changeCamera(position: CameraPosition)`


#### Photo Camera delegate

`func photoCamera(photoCamera: PhotoCamera, didTakePhoto image: UIImage)`

`func photoCamera(photoCamera: PhotoCamera, didTriggerError error: Camera.Error)`

### QRCodeScanner Example:
```swift
let scanner = QRCodeScanner()
func prepareQRCodeSCanner() {
  do {
    try await camera.prepare()
  } catch {
    // error handling
  }

  // add previewLayer to any view
  view.layer.addSublayer(scanner.previewLayer)
  scanner.previewLayer.frame = self.view.bounds
    
  // set camera delegate
  scanner.delegate = self
    
  // request authorization status
  let granted = await scanner.requestAuthorizationStatus()
    
  switch granted {
  case true:
    self.scanner.startSession()
  case false:
    // handle denied status
    break
  }
}
```

#### QRCodeScanner delegate
`func codeScanned(code: String, boundingRect: CGRect)`

`func scanFailure()`
