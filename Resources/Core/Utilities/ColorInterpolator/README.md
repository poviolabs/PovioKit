# ColorInterpolator

A simple way of interpolating multiple colors at a time.

## Usage

Creating a range of interpolated colors between `red` and `green` is as easy as:

```swift
let interpolator: ColorInterpolator = LinearColorInterpolator()
let colors = stride(from: 0.0, to: 1, by: 0.1).compactMap { try? interpolator.interpolate(.red, with: .green, percentage: $0) }
```

Interpolating multiple colors:

```swift
let colors: [UIColor] = [...]
let percentage: CGFloat = ...
try? colorInterpolator.interpolate(colorPoints: colors, percentage: percentage)
```

## Source code
You can find source code [here](/Sources/Core/Utilities/ColorInterpolator/ColorInterpolator.swift).
