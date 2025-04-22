<p align="center">
    <img src="Resources/PovioKit.png" width="400" max-width="90%" alt="PovioKit" />
</p>

<p align="center">
    <a href="https://swiftpackageregistry.com/poviolabs/PovioKit" alt="Package">
        <img src="https://img.shields.io/badge/SPM-Swift-lightgrey.svg" />
    </a>
    <a href="https://www.swift.org" alt="Swift">
        <img src="https://img.shields.io/badge/Swift-5-orange.svg" />
    </a>
    <a href="./LICENSE" alt="License">
        <img src="https://img.shields.io/badge/Licence-MIT-red.svg" />
    </a>
    <a href="https://github.com/poviolabs/PovioKit/actions/workflows/Tests.yml" alt="Tests Status">
        <img src="https://github.com/poviolabs/PovioKit/actions/workflows/Tests.yml/badge.svg" />
    </a>
</p>

<p align="center">
    Welcome to <b>PovioKit</b>. A modular library collection. Written in Swift.
</p>

## Packages

| [Core](Resources/Core) | [Networking](Resources/Networking) | [PromiseKit](Resources/PromiseKit) | [Utilities](Resources/Utilities) | [Async](Resources/Async) | [UIKit](Resources/UI/UIKit) | [SwiftUI](Resources/UI/SwiftUI) | 
| :-: | :-: | :-: | :-: | :-: | :-: | :-: |

## Installation

### Swift Package Manager
- In Xcode, click `File` -> `Add Package Dependencies...`  
- Insert `https://github.com/poviolabs/PovioKit` in the Search field.
- Select a desired `Dependency Rule`. Usually "Up to Next Major Version" with "5.1.0".
- Select "Add Package" button and check one or all given products from the list:
  - *PovioKitCore* (core library)
  - *PovioKitNetworking* (networking library built on top of Alamofire, has dependency on `PovioKitPromise` package)
  - *PovioKitPromise* (lightweight promises library)
  - *PovioKitUtilities* (utility components, has dependency on `PovioKitCore` package)
  - *PovioKitAsync* (async/await components)
  - *PovioKitUIKit* (UIKit components, has dependency on `PovioKitCore` and `PovioKitUtilities` package)
  - *PovioKitSwiftUI* (SwiftUI components, has dependency on `PovioKitCore` package)
- Select "Add Package" again and you are done.

### Migration

Please read the [Migration](MIGRATING.md) document.

## License

PovioKit is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
