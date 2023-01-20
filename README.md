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

| [Core](Resources/Core) | [UI](Resources/UI) | [Networking](Resources/Networking) | [PromiseKit](Resources/PromiseKit) | [Auth](Resources/Auth)
| :-: | :-: | :-: | :-: | :-: |

## Installation

### Swift Package Manager
- In Xcode, click `File` -> `Add Packages...`  
- Insert `https://github.com/poviolabs/PovioKit` in the Search field.
- Select a desired `Dependency Rule`. Usually "Up to Next Major Version" with "2.0.0".
- Select "Add Package" button and check one or all given products from the list:
  - *PovioKit* (core)
  - *PovioKitNetworking* (networking library, depends on `core` and `promise` package)
  - *PovioKitPromise* (lightweight promises library)
  - *PovioKitUI* (UI components)
  - *PovioKitAuthApple* (Apple auth components)
  - *PovioKitGoogleApple* (Google auth components)
  - *PovioKitFacebookApple* (Facebook auth components)
- Select "Add Package" again and you are done.

### Migration

Please read the [Migration](MIGRATING.md) document.

## License

PovioKit is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
