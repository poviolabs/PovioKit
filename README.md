<p align="center">
    <img src="https://raw.githubusercontent.com/poviolabs/PovioKit/master/PovioKit.png" width="400" max-width="90%" alt="PovioKit" />
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
### Core libraries

| Utilities |
| :--- |
| [AppVersionValidator](Sources/Core/Utilities/AppVersionValidator/AppVersionValidator.swift) |
| [AttributedStringBuilder](Resources/Core/Utilities/AttributedStringBuilder/) |
| [Broadcast](Resources/Core/Utilities/Broadcast/) |
| [BundleReader](Sources/Core/Utilities/BundleReader/BundleReader.swift) |
| [ColorInterpolator](Resources/Core/Utilities/ColorInterpolator/) |
| [Delegated](Resources/Core/Utilities/Delegated/) |
| [DispatchTimer](Resources/Core/Utilities/DispatchTimer/) |
| [ImageSource](Sources/Core/Utilities/ImageSource/ImageSource.swift) |
| [Logger](Resources/Core/Utilities/Logger/) |
| [SignInWithApple](Resources/Core/Utilities/SignInWithApple/) |
| [StartupService](Resources/Core/Utilities/StartupService/) |
| [Throttler](Resources/Core/Utilities/Throttler/) |
| [UserDefaults](Resources/Core/Utilities/PropertyWrapper/UserDefaults/) |
| [XCConfigValue](Resources/Core/Utilities/PropertyWrapper/XCConfigValue) |

### Core extensions

| UIKit | Foundation | MapKit | Other |
| :--- | :--- | :--- | :--- |
| [UIView](Sources/Core/Extensions/UIKit/UIView+Povio.swift) | [String](Sources/Core/Extensions/Foundation/String+Povio.swift) | [MKMapView](Sources/Core/Extensions/MapKit/MKMapView+PovioKit.swift) | [SKStoreReviewController](Sources/Core/Extensions/Other/SKStoreReviewController+PovioKit.swift) |
| [UICollectionView](Sources/Core/Extensions/UIKit/UICollectionView+Povio.swift) | [Data](Sources/Core/Extensions/Foundation/Data+Povio.swift) | [MKPolygon](Sources/Core/Extensions/MapKit/MKPolygon+PovioKit.swift) | [XCTestCase](Sources/Core/Extensions/Other/XCTestCase+PovioKit.swift) |
| [UITableView](Sources/Core/Extensions/UIKit/UITableView+Povio.swift) | [Collection](Sources/Core/Extensions/Foundation/Collection+Povio.swift) | [MKAnnotationView](Sources/Core/Extensions/MapKit/MKAnnotationView+PovioKit.swift) | |
| [UIColor](Sources/Core/Extensions/UIKit/UIColor+Povio.swift) | [URL](Sources/Core/Extensions/Foundation/URL+Povio.swift) | [MKCircle](Sources/Core/Extensions/MapKit/MKCircle+PovioKit.swift) | |
| [UIDevice](Sources/Core/Extensions/UIKit/UIDevice+Povio.swift) | [Optional](Sources/Core/Extensions/Foundation/Optional+Povio.swift) | | |
| [UIImage](Sources/Core/Extensions/UIKit/UIImage+Povio.swift) | [Result](Sources/Core/Extensions/Foundation/Result+Povio.swift) | | |
| [UIEdgeInsets](Sources/Core/Extensions/UIKit/UIEdgeInsets+Povio.swift) | [DecodableDictionary](Sources/Core/Extensions/Foundation/DecodableDictionary+Povio.swift) | | |
| [UIApplication](Sources/Core/Extensions/UIKit/UIApplication+Povio.swift) | [DispatchTimeInterval](Sources/Core/Extensions/Foundation/DispatchTimeInterval+Povio.swift) | | |
| [UIProgressView](Sources/Core/Extensions/UIKit/UIProgressView+Povio.swift) | [Encodable](Sources/Core/Extensions/Foundation/Encodable+Povio.swift) | | |
| [UIResponder](Sources/Core/Extensions/UIKit/UIResponder+Povio.swift) | [Double](Sources/Core/Extensions/Foundation/Double+Povio.swift) | | |

### UI

| Components |
| :--- |
| [ActionButton](Resources/UI/ActionButton/) |
| [GradientView](Resources/UI/GradientView/) |
| [PaddingLabel](Resources/UI/PaddingLabel/) |
| [DynamicCollectionCell](Resources/UI/DynamicCollectionCell/) |
| [ProfileImageView](Resources/UI/ProfileImageView) |
| [TextField](Resources/UI/TextField) |
### Networking

[AlamofireNetworkClient](Resources/Networking/AlamofireNetworkClient/)

### PromiseKit

[PromiseKit](Resources/PromiseKit/)


## Installation

### Swift Package Manager
- In Xcode, click `File` -> `Add Packages...`  
- Insert `https://github.com/poviolabs/PovioKit` in the search field.
- Select `Dependency Rule` "Up to Next Major Version" with "2.0.0"

Currently, there are three packages to choose from:
- *PovioKit* (core)
- *PovioKitNetworking* (networking library, depends on `core` and `promise` package)
- *PovioKitPromise* (lightweight promises library)
- *PovioKitUI* (UI components)

### Migration

Please read the [Migration](MIGRATING.md) document.

## License

PovioKit is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
