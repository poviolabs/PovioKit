# Dialog

A UI component that effectively replaces and extends native UIActionSheet.  

We can use the Dialog component to present a modal screen from the bottom (default behavior) or the top or in the center of the screen. It has a tap-to-dismiss gesture (outside of the content view), an option to be presented with the custom animation and it is dynamically expandable based on the content height.

## Modifiers:
**DialogPosition**: Dialog position on the screen
```swift
public enum DialogPosition {
  case bottom
  case top
  case center
}
```
**DialogContentWidth**: Set custom content width or horizontal insets
```swift
public enum DialogContentWidth {
  case normal
  case customWidth(CGFloat)
  case customInsets(leading: CGFloat, trailing: CGFloat)
}
```
**DialogAnimationType**: Dialog animation types
```swift
public enum DialogAnimationType {
  case fade
  case custom(DialogTransitionAnimation)
}
```
**setDialogBackground()**: Sets content background color
```swift
  func setDialogBackground(color: UIColor, alpha: CGFloat = 1.0) {
    backgroundView.backgroundColor = color.withAlphaComponent(alpha)
  }
```
## Examples:

### Define subclass of DialogViewController:
```swift
class DialogExampleViewController: DialogViewController<DialogContentView> {
  override init(contentView: DialogContentView,
                position: DialogPosition,
                width: DialogContentWidth = .normal,
                animation: DialogAnimationType? = .none) {
    super.init(contentView: contentView, position: position, width: width, animation: animation)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
  }
}

// MARK: - Private Methods
private extension DialogExampleViewController {
  func setupViews() {
    (contentView as? DialogExampleContentView)?.doneCallback = {
      self.dismiss(animated: true)
    }
  }
}
```


### Presenting custom DialogViewController:
```swift
let dialog = DialogExampleViewController(contentView: DialogExampleContentView(), position: .center, width: .customWidth(200), animation: .fade)
self.navigationController?.present(dialog, animated: true)
```

### Creating custom animation:
```swift
class CustomAnimation: NSObject, DialogTransitionAnimation {
  var duration: TimeInterval = 0.5
  var presenting: Bool
  var originFrame: CGRect = .zero
  
  init(presenting: Bool = true) {
    self.presenting = presenting
  }
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return duration
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    if presenting {
      guard let toView = transitionContext.view(forKey: .to) else { return }
      let containerView = transitionContext.containerView
      containerView.addSubview(toView)
      toView.transform = CGAffineTransform(rotationAngle: .pi)
      UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
        toView.transform = .identity
      }, completion: { _ in
        transitionContext.completeTransition(true)
      })
    } else {
      guard let fromView = transitionContext.view(forKey: .from) else { return }
      fromView.transform = .identity
      UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
        fromView.transform = CGAffineTransform(rotationAngle: .pi)
      }, completion: { _ in
        transitionContext.completeTransition(true)
      })
    }
  }
}

```
