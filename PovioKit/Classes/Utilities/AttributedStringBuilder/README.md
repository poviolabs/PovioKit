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

A common problem we can face is when we want to change attributes of only a specific substring of the text we are dealing with. Lets say we want to change the color of the word "custom" to blue with bigger font.

Without using `AttributedStringBuilder`, we would come up with something like this:

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

Using `AttributedStringBuilder` we can simplify into:

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

What if we need an actual `NSAttributedString` instance, not just applying changes to a `UILabel`? We can do that as well:

```Swift
let attributedText = Builder(text: "My custom text")
  .setFont(.boldSystemFont(ofSize: 14))
  .setTextColor(.black)
  .setParagraphStyle(lineSpacing: 10,
                     heightMultiple: 1,
                     lineHeight: 7,
                     lineBreakMode: .byWordWrapping,
                     textAlignment: .center)
  .create()
```

If, for some reason, we need a `mutable` instance, we replace `.create()` with `.createMutable()`.

We've shown how we can configure a couple of attributed parameters, like color, font, paragraph style, ... But what if we want to configure any other attribute? 
The methods shown through examples above are actually just convenience methods calling generic `addAttribute(key: NSAttributedString.Key, object: Any?)` method. We can use this method instead to configure any other attributes we'd like. 

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

Povio Inc., services@poviolabs.com

## License

PovioKit is available under the MIT license. See the LICENSE file for more info.
