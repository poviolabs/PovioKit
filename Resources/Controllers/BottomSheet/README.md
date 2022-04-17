#  BottomSheet

A UI component that effectively replaces and extends native UIActionSheet.  

## Overview  

BottomSheet has the following characteristics:
- dynamically expandable based on the content height
- swipe down gesture to dismiss
- tap gesture behind the content to dismiss
- custom transition animations

### Components:

- **BottomSheet**: *Main component that acts as a "parent" view controller for all Steps*
```swift
class BottomSheet<ContentView: BottomSheetContentView>: UIViewController
```
- **BottomSheetContentView**: *Main content view*
```swift
class BottomSheetContentView: UIView
```
- **BottomSheetStep**: *Protocol that defines every Step*
```swift 
public protocol BottomSheetStep: UIViewController
```
- **BottomSheetDataSource**: *Class that holds a list of all Steps and is handling navigation from Step to Step (next and previous)*
```swift
class BottomSheetDataSource: NSObject
```
- **LazyStep**: 
```swift
typealias LazyStep = () -> BottomSheetStep
```
- **AnimatorFactory**: *Enum that holds predefined transition Animations*
```swift
enum AnimatorFactory
```

### Default animations:
- slideInSlideOut
- fadeIn
- fadeOut
- fadeInFadeOut
- popInPopOut  

Besides these predefined animations, it is possible to combine two or more animations with the available `composite` function, but also to create custom animation with return type: ```typealias Animator = (UIView, UIView) -> Void```

## Usage

The main part of this component is ```BottomSheet``` class which is UIViewController that holds all the sub-controllers (or 'Steps' as it is called locally). We provide a list of Steps in the init method, and also mainContentView that needs to inherit ```BottomSheetContentView```.  
> One important note here:  
we need to add BottomSheetContentView's contentView as a subview in our implementation (see code below and also Example section for more details)
```swift
addSubview(contentView)
contentView.snp.makeConstraints {
  $0.bottom.leading.trailing.equalToSuperview()
}
```

Every Step that we want in our BottomSheet must inherit from ```BottomSheetStep``` which is an open protocol that can be extended by our needs. Step represents the concrete UIViewController that we want to display and we create it as any other UIViewController. The main thing here is that UI constraints of the contentView are properly set so the BottomSheet can dynamically set height based on the content.

When we create an instance of our BottomSheet implementation, we present it on the current UINavigationController as any other modal UIViewController.

## Example:
```swift
class RootViewController: UIViewController {
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let firstStep: () -> BottomSheetStep = { FirstStepViewController() }
    let secondStep: () -> BottomSheetStep = { SecondStepViewController() }
    let thirdStep: () -> BottomSheetStep = { ThirdStepViewController() }
    let mainVC = BottomSheetViewController(steps: [firstStep, secondStep, thirdStep])
    navigationController?.present(mainVC, animated: true)
  }
}
```
```swift
protocol MainBottomSheet: UIViewController {
  func dismissBottomSheet()
  func nextStep()
  func previousStep()
}

class BottomSheetViewController: BottomSheet<BottomSheetContentView> {
  init(steps: [BottomSheet<BottomSheetContentView>.LazyStep]) {
    super.init(steps: steps, mainContentView: BottomSheetParentContentView())
  }
  
  /// required init?(coder: NSCoder)
  
  override func configureStep(beforeTransition step: BottomSheetStep) {
    (step as? StepViewController)?.wizard = self
  }
}

extension BottomSheetViewController: MainBottomSheet {
  func dismissBottomSheet() { dismiss(animated: true) }
  
  func nextStep() {
    nextStep(transitionDuration: 0.5, animator: .fadeIn(animationDuration: 1))
  }
  
  func previousStep() {
    previousStep(transitionDuration: 0.5, animator: .fadeInFadeOut(animationDuration: 1))
  }
}
```
```swift
class BottomSheetParentContentView: BottomSheetContentView {  
  override init() {
    super.init()
    addSubview(contentView)
    contentView.snp.makeConstraints {
      $0.bottom.leading.trailing.equalToSuperview()
    }
  }

  /// required init?(coder aDecoder: NSCoder)
}
```
```swift
protocol StepViewController: BottomSheetStep {
  var wizard: MainBottomSheet? { get set }
  
  func didTapNextButton()
  func didTapPreviousButton()
}

```
```swift
class FirstStepViewController: StepViewController {
  private lazy var contentView = FirstStepContentView()
  var wizard: MainBottomSheet?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
  }
  
  override func loadView() {
    view = contentView
  }
  
  func didTapNextButton() {
    self.wizard?.nextStep()
  }
  
  func didTapPreviousButton() { }
}

// MARK: - Private Methods
private extension FirstStepViewController {
  func setupViews() {
    contentView.nextButtonCallback = didTapNextButton
  }
}

```
