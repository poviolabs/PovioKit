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


## List of available libraries

| Utils | Networking | Protocols | Views |
| --- | --- | --- | --- |
| [AttributedStringBuilder](Resources/Utilities/AttributedStringBuilder/) | [AlamofireNetworkClient](Resources/Networking/AlamofireNetworkClient/) | [Data Source](Resources/Protocols/DataSource/) | [GradientView](Resources/Views/GradientView/) |
| [StartupService](Resources/Utilities/StartupService/) | | [PaddingLabel](Resources/Views/PaddingLabel/) |
| [Broadcast](Resources/Utilities/Broadcast/) | | [DynamicCollectionCell](Resources/Views/DynamicCollectionCell/) |
| [PromiseKit](Resources/Utilities/PromiseKit/) | | |
| [ColorInterpolator](Resources/Utilities/ColorInterpolator/) | | |
| [DispatchTimer](Resources/Utilities/DispatchTimer/) | | |
| [Logger](Resources/Utilities/Logger/) | | |
| [Throttler](Resources/Utilities/Throttler/) | | |
| [SignInWithApple](Resources/Utilities/SignInWithApple/) | | |

## List of available extensions

| UIKit | Foundation | MapKit |
| --- | --- | --- |
| [UIView](Sources/Extensions/UIKit/UIView+Povio.swift) | [String](Sources/Extensions/Foundation/String+Povio.swift) | [MKMapView](Sources/Extensions/MapKit/MKMapView+PovioKit.swift) |
| [UICollectionView](Sources/Extensions/UIKit/UICollectionView+Povio.swift) | [Data](Sources/Extensions/Foundation/Data+Povio.swift) | [MKPolygon](Sources/Extensions/MapKit/MKPolygon+PovioKit.swift) |
| [UITableView](Sources/Extensions/UIKit/UITableView+Povio.swift) | [Collection](Sources/Extensions/Foundation/Collection+Povio.swift) | [MKAnnotationView](Sources/Extensions/MapKit/MKAnnotationView+PovioKit.swift) |
| [UIColor](Sources/Extensions/UIKit/UIColor+Povio.swift) | [URL](Sources/Extensions/Foundation/URL+Povio.swift) | [MKCircle](Sources/Extensions/MapKit/MKCircle+PovioKit.swift) |
| [UIDevice](Sources/Extensions/UIKit/UIDevice+Povio.swift) | [Optional](Sources/Extensions/Foundation/Optional+Povio.swift) | |
| [UIImage](Sources/Extensions/UIKit/UIImage+Povio.swift) | [Result](Sources/Extensions/Foundation/Result+Povio.swift) | |
| [UIEdgeInsets](Sources/Extensions/UIKit/UIEdgeInsets+Povio.swift) | [DecodableDictionary](Sources/Extensions/Foundation/DecodableDictionary+Povio.swift) | |
| [UIApplication](Sources/Extensions/UIKit/UIApplication+Povio.swift) | [DispatchTimeInterval](Sources/Extensions/Foundation/DispatchTimeInterval+Povio.swift) | |
| [UIProgressView](Sources/Extensions/UIKit/UIProgressView+Povio.swift) | [Encodable](Sources/Extensions/Foundation/Encodable+Povio.swift) | |
| [UIResponder](Sources/Extensions/UIKit/UIResponder+Povio.swift) | |


## Installation

### Swift Package Manager

In Xcode, click `File` -> `Swift Packages` -> `Add Package Dependency` and enter `https://github.com/poviolabs/PovioKit`.

Currently, there are three packages to choose from:
- PovioKit (core)
- PovioKitNetworking (networking library)
- PovioKitPromise (lightweight promises library)


## License

PovioKit is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
