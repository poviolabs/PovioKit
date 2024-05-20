# XCConfigValue

XCConfigValue is a property wrapper that helps you to access your build configuration values easily.

## Usage
Usually we have build configuration files like `Production.xcconfig`, `Development.xcconfig`. There you define something like this:

```xcconfig
API_BASE_URL = api.example.com
SUBSCRIBE_LIMIT = 10
```

In your app `info.plist` you should reference them using syntax `$(BUILD_SETTING_NAME)`

An example of @XCConfigValue would look like this:

```swift
enum Environment {
  @XCConfigValue(key: "API_BASE_URL")
  static var baseUrl: String
  
  @XCConfigValue(key: "SUBSCRIBE_LIMIT")
  static var subscribeLimit: Int
}
```

## Source code
You can find source code [here](/Sources/Utilities/PropertyWrapper/XCConfigValue.swift).
