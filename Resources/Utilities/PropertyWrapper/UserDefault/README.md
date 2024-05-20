#  UserDefaults

UserDefault helps you to use `UserDefaults` in more simpler way using `@propertyWrapper`

## Usage

```swift
struct Flags {
  @UserDefault(defaultValue: false, key: "your_key")
  static var screenFlag: Bool
}
```

## Tips

Since you can share data between apps, we recommend to created a shared instance of `UserDefaults` on your app:


```swift
extension UserDefaults {
  static var shared: UserDefaults {
    let combined = UserDefaults.standard
    combined.addSuite(named: "com.your.app")
    return combined
  }
}
```

than you can create a custom initializer in order to not replicate storage through the app


```swift
extension UserDefault {
  init(defaultValue: Value, key: String) {
    self.init(defaultValue: defaultValue, key: key, storage: .shared)
  }
}
```

## Source code
You can find source code [here](/Sources/Utilities/PropertyWrapper/UserDefault.swift).
