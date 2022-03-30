<p align="center">
    <img src="https://raw.githubusercontent.com/poviolabs/PovioKit/master/PovioKit.png" width="400" max-width="90%" alt="PovioKit" />
</p>

<p align="center">
    <a href="https://cocoapods.org/pods/PovioKit">
        <img src="https://img.shields.io/cocoapods/p/PovioKit.svg?style=flat" alt="Platform" />
    </a>
    <a href="https://swift.org/blog/swift-5-3-released/">
        <img src="https://img.shields.io/badge/Swift-5.3-orange.svg?style=flat" alt="Swift" />
    </a>
    <a href="https://cocoapods.org/pods/PovioKit">
        <img src="https://img.shields.io/cocoapods/l/PovioKit.svg?style=flat" alt="License" />
    </a>
    <a href="https://github.com/poviolabs/PovioKit/actions/workflows/CI.yml">
        <img src="https://github.com/poviolabs/PovioKit/actions/workflows/CI.yml/badge.svg" alt="CI status" />
    </a>
</p>

<p align="center">
    Welcome to <b>PovioKit</b>. A modular library collection. Written in Swift.
</p>

## Packages
### Core libraries

| Utils | Protocols | Views |
| --- | --- | --- |
| [AttributedStringBuilder](Resources/Utilities/AttributedStringBuilder/) | [Data Source](Resources/Protocols/DataSource/) | [GradientView](Resources/Views/GradientView/) |
| [StartupService](Resources/Utilities/StartupService/) | [PaddingLabel](Resources/Views/PaddingLabel/) |
| [Broadcast](Resources/Utilities/Broadcast/) | [DynamicCollectionCell](Resources/Views/DynamicCollectionCell/) |
| [ColorInterpolator](Resources/Utilities/ColorInterpolator/) | |
| [DispatchTimer](Resources/Utilities/DispatchTimer/) | |
| [Logger](Resources/Utilities/Logger/) | |
| [Throttler](Resources/Utilities/Throttler/) | |
| [SignInWithApple](Resources/Utilities/SignInWithApple/) | |
| [UserDefaults](Resources/Utilities/PropertyWrapper/UserDefaults/) | |
| [XCConfigValue](Resources/Utilities/PropertyWrapper/XCConfigValue/) | |

### Core extensions

| UIKit | Foundation | MapKit |
| --- | --- | --- |
| [UIView](Sources/Core/Extensions/UIKit/UIView+Povio.swift) | [String](Sources/Core/Extensions/Foundation/String+Povio.swift) | [MKMapView](Sources/Core/Extensions/MapKit/MKMapView+PovioKit.swift) |
| [UICollectionView](Sources/Core/Extensions/UIKit/UICollectionView+Povio.swift) | [Data](Sources/Core/Extensions/Foundation/Data+Povio.swift) | [MKPolygon](Sources/Core/Extensions/MapKit/MKPolygon+PovioKit.swift) |
| [UITableView](Sources/Core/Extensions/UIKit/UITableView+Povio.swift) | [Collection](Sources/Core/Extensions/Foundation/Collection+Povio.swift) | [MKAnnotationView](Sources/Core/Extensions/MapKit/MKAnnotationView+PovioKit.swift) |
| [UIColor](Sources/Core/Extensions/UIKit/UIColor+Povio.swift) | [URL](Sources/Core/Extensions/Foundation/URL+Povio.swift) | [MKCircle](Sources/Core/Extensions/MapKit/MKCircle+PovioKit.swift) |
| [UIDevice](Sources/Core/Extensions/UIKit/UIDevice+Povio.swift) | [Optional](Sources/Core/Extensions/Foundation/Optional+Povio.swift) | |
| [UIImage](Sources/Core/Extensions/UIKit/UIImage+Povio.swift) | [Result](Sources/Core/Extensions/Foundation/Result+Povio.swift) | |
| [UIEdgeInsets](Sources/Core/Extensions/UIKit/UIEdgeInsets+Povio.swift) | [DecodableDictionary](Sources/Core/Extensions/Foundation/DecodableDictionary+Povio.swift) | |
| [UIApplication](Sources/Core/Extensions/UIKit/UIApplication+Povio.swift) | [DispatchTimeInterval](Sources/Core/Extensions/Foundation/DispatchTimeInterval+Povio.swift) | |
| [UIProgressView](Sources/Core/Extensions/UIKit/UIProgressView+Povio.swift) | [Encodable](Sources/Core/Extensions/Foundation/Encodable+Povio.swift) | |
| [UIResponder](Sources/Core/Extensions/UIKit/UIResponder+Povio.swift) | |

### Networking

[AlamofireNetworkClient](Resources/Networking/AlamofireNetworkClient/)

### PromiseKit

[PromiseKit](Resources/PromiseKit/)


## Installation

### Swift Package Manager

In Xcode, click `File` -> `Swift Packages` -> `Add Package Dependency` and enter `https://github.com/poviolabs/PovioKit`.

Currently, there are three packages to choose from:
- *PovioKit* (core)
- *PovioKitNetworking* (networking library, depends on "core" and "promise" package)
- *PovioKitPromise* (lightweight promises library)

### Migration

Please read the [Migration](MIGRATING.md) document.

## License

PovioKit is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
