#  EXIF

EXIF is a wrapper around Image I/O framework APIs that can be used to modify EXIF metadata without recompressing the image data.

## Overview

When initialize, EXIF is provided with the image in the ``ExifImageSource`` as Data or an URL.

### Public methods:
- Read EXIF from the image
```swift
func read() -> Promise<[String: Any]>
```
- Write EXIF metadata to the image
> Note: Keys for the new values must be part of the [EXIF Dictionary Keys](https://developer.apple.com/documentation/imageio/exif_dictionary_keys)
```swift
func update(_ newValue: [CFString: String]) -> Promise<Data>
```

## Examples
### Init:
```swift
do {
    let data = try Data(contentsOf: imageUrl)
    let manager = Exif(source: .data(data))
} catch {
    Logger.error("Could not create ExifManager", params: ["reason": error.localizedDescription])
}
```

### Read EXIF:
```swift
manager.read().finally { exif, error in
    if let exif {
        Logger.debug("Image metadata:", params: ["metadata": exif.description])
    }
}
```

### Write EXIF:
```swift
let metadata = [kCGImagePropertyExifUserComment: "This is a really nice picture."]
manager.update(metadata).finally { data, error in
    if let data {
        Logger.debug("Image metadata saved!")
    }
}
```

## Source code
You can find source code [here](/Sources/Core/Utilities/Exif/Exif.swift).
