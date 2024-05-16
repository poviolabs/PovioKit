# DispatchTimer

This is a `NSTimer` replacement using GCD.

## Usage

Repeatedly execute action every n seconds

```swift
let myTimer = DispatchTimer()
myTimer.schedule(interval: seconds(10), repeating: true, on: .main) { [weak self] in
  self?.refreshProgress()
}
```

Repeatedly execute action every n seconds, without timer reference

```swift
DispatchTimer.scheduled(interval: seconds(10), repeating: true, on: .main) { [weak self] in
  self?.refreshProgress()
}
```

Execute action only once after n seconds

```swift
let myTimer = DispatchTimer()
myTimer.schedule(interval: seconds(10), repeating: false, on: .main) { [weak self] in
  self?.refreshProgress()
}
```

Cancel or terminate timer

```swift
myTimer.stop() // you could eventually just nillify reference and the timer is terminated
```

## Source code
You can find source code [here](/Sources/Core/Utilities/DispatchTimer/DispatchTimer.swift).
