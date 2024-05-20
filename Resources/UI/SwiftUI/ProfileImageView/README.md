# ProfileImageView

A `View` subclass intended to replace `UIImageView` and all the configuration that goes with it for user's profile image.

## Usage

### Example: Implementation in SwiftUI
```swift
struct ContentView: View {
  var body: some View {
      ProfileImageView(image: .init(<Image name>))
        .borderWidth(3)
        .borderColor(.red)
        .badging(.some(badge: .init(image: .init(systemName: "plus"),
                                    contentMode: .fit,
                                    tintColor: .black,
                                    backgroundColor: .green,
                                    alignment: .bottomTrailing)))
        .onBadgeTap {
          print("badge tapped")
        }
        .onProfileTap {
          print("profile tapped")
        }
        .url(<Picture URL>, placeholder: <Optional Placeholder>)
        .frame(width: 60, height: 60)
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
  
  profileImageView.image = .init(<Image name>)
  profileImageView.borderWidth = 2
  profileImageView.borderColor = .green
  profileImageView.contentMode = .fit
  profileImageView.badging = .some(badge: .init(image: .init(systemName: "plus"), backgroundColor: .green, alignment: .bottomTrailing))
  profileImageView.addActionOnBadgeTap {
    print("badge tapped")
  }
  
  profileImageView.addActionOnProfileTap {
    print("profile tapped")
  }
  
  hostingController.rootView = profileImageView
}
```

Download picture url
```swift
profileImageView.set(<Picture URL>, placeholder: <Optional Placeholder>)
```

## Source code
You can find source code [here](/Sources/UI/SwiftUI/Views/ProfileImageView).
