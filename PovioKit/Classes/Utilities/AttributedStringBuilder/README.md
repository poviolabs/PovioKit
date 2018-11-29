# AttributedStringBuilder

Create `NSAttributedString`s with ease. 

## Example

Let's say we need to style a label with underlined text, custom color and font. A standard strategy would be to create a `NSAttributedString` instance and initialize it with required attributes. For instance:

```Swift
let attributedText = NSAttributedString(string: "My custom text",
                                        attributes: [.font: UIFont.boldSystemFont(ofSize: 14),
                                                     .foregroundColor: UIColor.red,
                                                     .underlineStyle: NSUnderlineStyle.styleSingle.rawValue])
let label = UILabel()
label.attributedText = attributedText
```

Using `AttributedStringBuilder` we can achieve the same with:

```Swift
let label = UILabel()
label.text = "My custom text"
label.bd.apply {
  $0.setTextColor(.red)
  $0.setFont(.boldSystemFont(ofSize: 14))
  $0.setUnderlineStyle(.styleThick)
}
```

## Advance usage

A common problem we are usually solving with `NSAttributedString` is we want to change attributes of only specific substring of the text we are dealing with. Lets say we want to change the color of the word "custom" to blue with bigger font.

Without using `AttributedStringBuilder` this would look something like:

```Swift
let text = "My custom text"
let attributedText = NSMutableAttributedString(string: text,
                                               attributes: [.font: UIFont.boldSystemFont(ofSize: 14), 
                                                            .foregroundColor: UIColor.red,
                                                            .underlineStyle: NSUnderlineStyle.styleSingle.rawValue])
if let range = text.range(of: "custom") {
  let rangeInText = NSRange(range, in: text)
  attributedText.addAttributes([.font: UIFont.boldSystemFont(ofSize: 18),
                                .foregroundColor: UIColor.blue], 
                               range: rangeInText)
}
let label = UILabel()
label.attributedText = attributedText
```

Using `AttributedStringBuilder` we can simply into:

```SWift
let label = UILabel()
label.text = "My custom text"
label.bd.apply {
  $0.setTextColor(.red)
  $0.setFont(.boldSystemFont(ofSize: 12))
  $0.setUnderlineStyle(NSUnderlineStyle.styleThick.rawValue)
  _ = try? $0.setFont(.boldSystemFont(ofSize: 18), substring: "custom")
  _ = try? $0.setTextColor(.blue, substring: "custom")
}
```

## Installation

PovioKit/Utilities/AttributedStringBuilder is available through PovioKit cocoapod. To install
it, simply add the following line to your Podfile:

```ruby
pod 'PovioKit/Utilities/AttributedStringBuilder', :git => 'git@github.com:poviolabs/PovioKit.git', :branch => 'feature/attributed-string-builder'
```

or if you want the whole PovioKit package:
```ruby
pod 'PovioKit', :git => 'git@github.com:poviolabs/PovioKit.git', :branch => 'feature/poviokit-pod-setup'
```

## Author

Toni Kocjan, toni.kocjan@poviolabs.com

## License

PovioKit is available under the MIT license. See the LICENSE file for more info.
