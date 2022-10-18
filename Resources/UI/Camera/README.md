# Camera

A UI component that simplifies handling with camera. `PhotoCamera` & `QRCodeScanner`.

### PhotoCamera Example:
```swift
let camera = PhotoCamera()
func prepareCamera() {
  try? camera.prepare()
    
  // add previewLayer to any view
  view.layer.addSublayer(camera.previewLayer)
  camera.previewLayer.frame = self.view.bounds
    
  // set camera delegate
  camera.delegate = self
    
  // get authorization status
  let status = await camera.getAuthorizationStatus()
    
  switch status {
  case .authorized:
    self.camera.startSession()
  case .denied:
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
`func photoCameraDidTakePhoto(_ image: UIImage)`

`func photoCameraDidTriggerError(_ error: Camera.Error)`



### QRCodeScanner Example:
```swift
let scanner = QRCodeScanner()
func prepareQRCodeSCanner() {
  scanner.prepare()
    
  // add previewLayer to any view
  view.layer.addSublayer(scanner.previewLayer)
  scanner.previewLayer.frame = self.view.bounds
    
  // set camera delegate
  scanner.delegate = self
    
  // get authorization status
  let status = await scanner.getAuthorizationStatus()
    
  switch status {
  case .authorized:
    self. scanner.startSession()
  case .denied:
    // handle denied status
    break
  }
}
```

#### QRCodeScanner delegate
`func codeScanned(code: String, boundingRect: CGRect)`

`func scanFailure()`




