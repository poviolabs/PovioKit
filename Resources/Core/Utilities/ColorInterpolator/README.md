# ColorInterpolator

A simple way of interpolating multiple colors at a time.

## Examples

Creating a range of interpolated colors between `red` and `green` is as easy as:

```Swift
let interpolator: ColorInterpolator = LinearColorInterpolator()
let colors = stride(from: 0.0, to: 1, by: 0.1).compactMap { try? interpolator.interpolate(.red, with: .green, percentage: $0) }
```

Interpolating multiple colors:

```Swift
let colors: [UIColor] = [...]
let percentage: CGFloat = ...
try? colorInterpolator.interpolate(colorPoints: colors, percentage: percentage)
```