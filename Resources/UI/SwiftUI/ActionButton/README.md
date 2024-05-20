# ActionButton

SwiftUI view intended to offer a ready-to-go Button with some generic configuration.

## Usage

### Example: Implementation in SwiftUI
```swift
struct ContentView: View {
  var body: some View {
      ActionButton {
        // do something when button is tapped
      }
      .title("button title")
      .font(.system(size: 14))
      .extraImage(titleRightImage: .init(image: .init(systemName: "arrow.right"), size: .init(width: 10, height: 10)))
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
actionButton.backgroundType = .linearGradient(LinearGradient(gradient: Gradient(colors: [.blue, .green]), startPoint: .top, endPoint: .bottom))
actionButton.cornerRadius = .custom(10)
actionButton.borderWidth = 3
actionButton.borderColor = .red
actionButton.addAction(action: someFunc)
actionButton.titleRightImage = .init(image: Image(systemName: "arrow.right"), size: .init(width: 14, height: 14))
```

## Source code
You can find source code [here](/Sources/UI/SwiftUI/Views/ActionButton/ActionButton.swift).
