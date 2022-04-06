# GenericButton

SwiftUI view intended to offer a ready-to-go Button with some generic configuration.

### Example: Implementation in SwiftUI
```swift
struct ContentView: View {
  var genericButton = GenericButton()
  
  // Optional - For configuration purposes
  init() {
    genericButton.properties.backgroundType = .linearGradient(LinearGradient(gradient: Gradient(colors: [.blue, .green]), startPoint: .top, endPoint: .bottom))
    genericButton.properties.cornerRadius = .rounded
    genericButton.properties.borderWidth = 3
    genericButton.properties.borderColor = .red
    genericButton.properties.extraImage = .right(Image(systemName: "arrow.right"))
    genericButton.setAction(action: someFunc)
  }
  
  var body: some View {
    genericButton
      .frame(width: 200, height: 70)
  }
}
```


### Example: Implementation in UIKit
```swift
var genericButton = GenericButton()
private func addGenericButton() {
  let hostingController = UIHostingController(rootView: genericButton)
    
  addChild(hostingController)
  view.addSubview(hostingController.view)
    
  hostingController.view.translatesAutoresizingMaskIntoConstraints = false
  hostingController.view.backgroundColor = .clear
  let constraints = [
    hostingController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
    hostingController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    hostingController.view.widthAnchor.constraint(equalToConstant: 200),
    hostingController.view.heightAnchor.constraint(equalToConstant: 70)
  ]
    
  NSLayoutConstraint.activate(constraints)
  hostingController.didMove(toParent: self)
}
```

Accessing some of methods & properties of `GenericButton`
```swift
genericButton.properties.backgroundType = .linearGradient(LinearGradient(gradient: Gradient(colors: [.blue, .green]), startPoint: .top, endPoint: .bottom))
genericButton.properties.cornerRadius = .custom(10)
genericButton.properties.borderWidth = 3
genericButton.properties.borderColor = .red
genericButton.setAction(action: someFunc)
genericButton.properties.extraImage = .right(Image(systemName: "arrow.right"))
```

