#  UserDefaults

UserDefault helps you to use `UserDefaults` in more simpler way using `@propertyWrapper`

## Usage

```swift
struct Flags {
  @UserDefault(defaultValue: false, key: "your_key")
  static var screenFlag: Bool
}
```

#### Resetting Values

If you need to reset a value to its default state, the `UserDefault` property wrapper provides a `resetValue` method. This method sets the value for the specified key back to its initial default value, allowing you to easily revert any changes made to the property.

Here's how you can use it:

```swift
Flags.$screenFlag.resetValue()
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
