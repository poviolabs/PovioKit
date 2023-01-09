# ActionButton

SwiftUI view intended to offer a ready-to-go Button with some generic configuration.

## Usage

### Example: Implementation in SwiftUI
```swift
struct ContentView: View {
  var actionButton = ActionButton()
  
  // Optional - For configuration purposes
  init() {
    actionButton.properties.backgroundType = .linearGradient(LinearGradient(gradient: Gradient(colors: [.blue, .green]), startPoint: .top, endPoint: .bottom))
    actionButton.properties.cornerRadius = .rounded
    actionButton.properties.borderWidth = 3
    actionButton.properties.borderColor = .red
    actionButton.properties.extraImage = .right(Image(systemName: "arrow.right"))
    actionButton.setAction(action: someFunc)
  }
  
  var body: some View {
    actionButton
      .frame(width: 200, height: 70)
  }
}
```


### Example: Implementation in UIKit
```swift
var actionButton = ActionButton()
private func addActionButton() {
  let hostingController = UIHostingController(rootView: actionButton)
    
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

Accessing some of methods & properties of `ActionButton`
```swift
actionButton.properties.backgroundType = .linearGradient(LinearGradient(gradient: Gradient(colors: [.blue, .green]), startPoint: .top, endPoint: .bottom))
actionButton.properties.cornerRadius = .custom(10)
actionButton.properties.borderWidth = 3
actionButton.properties.borderColor = .red
actionButton.setAction(action: someFunc)
actionButton.properties.extraImage = .right(Image(systemName: "arrow.right"))
```

## Source code
You can find source code [here](/Sources/UI/ActionButton/ActionButton.swift).
