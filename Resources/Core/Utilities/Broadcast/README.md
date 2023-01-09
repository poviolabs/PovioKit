# Broadcast

Implement `Observer / Listener` pattern with ease.

## Usage

In iOS, we often use the `delegate` pattern to delegate some responsibilites, or to notify objects of some events. But sometimes we don't want to limit ourselves to only one listener. Let's see an example of this in action:

```swift
protocol AppEventObserver {
  func keyboardWillShow(animationDuration: CGFloat, keyboardSize: CGSize)
  func keyboardWillHide(animationDuration: CGFloat, keyboardSize: CGSize)
}

...

class KeyboardBroadcast {
  let appEvents = Broadcast<AppEventObserver>()
  
  init() {
    _ = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { 
      appEvents.invoke {
        $0.keyboardWillShow(animationDuration: ..., keyboardSize: CGSize(...))
      }
    }
    _ = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { 
      appEvents.invoke {
        $0.keyboardWillHide(animationDuration: ..., keyboardSize: CGSize(...))
      }
    }
  }
}
```

Subscribing to keyboard notifications is as easy as:

```swift
let keyboardBrodcast = KeyboardBroadcast()

...

class ViewController: UIViewController, AppEventObserver {
  func viewDidLoad() {
    super.viewDidLoad()
    keyboardBrodcast.appEvents.add(self)
  }
  
  func keyboardWillShow(animationDuration: CGFloat, keyboardSize: CGSize) {
    ...
  }

  func keyboardWillHide(animationDuration: CGFloat, keyboardSize: CGSize) {
    ...
  }
}
```

## Source code
You can find source code [here](/Sources/Core/Utilities/Broadcast/Broadcast.swift).
