# ProfileImageView

A `View` subclass intended to replace `UIImageView` and all the configuration that goes with it for user's profile image.

### Example: Implementation in SwiftUI
```swift
struct ContentView: View {
  var profileImageView = ProfileImageView()
  
  // Optional - For configuration purposes
  init() {
    profileImageView.properties.placeHolder = Image(systemName: "person.circle.fill")
    profileImageView.imageTapped = { print("Image tapped") }
  }
  
    var body: some View {
      profileImageView
        .frame(width: 100, height: 100)
    }
}
```


### Example: Implementation in UIKit
```swift
var profileImageView = ProfileImageView()
private func addProfileImageView() {
  let hostingController = UIHostingController(rootView: profileImageView)
  
  addChild(hostingController)
  view.addSubview(hostingController.view)
  
  hostingController.view.translatesAutoresizingMaskIntoConstraints = false
  hostingController.view.backgroundColor = .clear
  let constraints = [
    hostingController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
    hostingController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    hostingController.view.widthAnchor.constraint(equalToConstant: 100),
    hostingController.view.heightAnchor.constraint(equalToConstant: 100)
  ]
  
  NSLayoutConstraint.activate(constraints)
  hostingController.didMove(toParent: self)
  
  profileImageView.imageTapped = { [weak self] in
    self?.someFunc()
  }
  
  profileImageView.badgeTapped = {
    print("Badge tapped")
  }
  
  hostingController.rootView = profileImageView
}
```

Accessing methods & properties of `ProfileImageView`
```swift
profileImageView.set(URL(string: "URL String"))
profileImageView.properties.badging = .some(badge: .init(image: Image(systemName: "plus"), backgroundColor: .green, borderColor: nil, borderWidth: nil))
```
