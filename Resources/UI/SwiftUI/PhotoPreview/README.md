# PhotoPreview

SwiftUI view intended to present an image or set of images in full-screen mode.

## Usage

### Example: Implementation in SwiftUI
```swift
struct ContentView: View {
  @State private var showPhotoPreview = false
  private var items: [PhotoPreviewItem] = [
    .init(image: Image("image1")),
    .init(url: .init(string: "remote-url"))
  ]
  
  var body: some View {
    Button {
      showPhotoPreview.toggle()
    } label: {
      Text("Show images")
    }
    .photoPreview(
      present: $showPhotoPreview,
      items: items
    )
  }
}
```
