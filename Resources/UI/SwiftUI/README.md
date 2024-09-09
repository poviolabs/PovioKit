# PovioKit: SwiftUI

A package including components to help you out developing for SwiftUI framework.

### Components

| Views                                                                                             | Platform                                               |                                                                             |
| :------------------------------------------------------------------------------------------------ | :----------------------------------------------------- | :-------------------------------------------------------------------------- |
| [PhotoPickerView](/Sources/UI/SwiftUI/Views/PhotoPickerView/PhotoPickerView.swift)                | iOS                                                    | Photo and Camera picker view used in combination with `PhotoPickerModifier` |
| [PhotoPreview](/Sources/UI/SwiftUI/Views/PhotoPreview/PhotoPreview.swift)                         | Present an image or set of images in full-screen mode. |
| [ProgressStyle](/Sources/UI/SwiftUI/Views/ProgressStyle/ProgressStyle.swift)                      | all                                                    | Customizable ProgressViewStyle                                              |
| [RemoteImage](/Sources/UI/SwiftUI/Views/RemoteImage/RemoteImage.swift)                            | all                                                    | Fetching remote images using Kingfisher                                     |
| [ScrollViewWithOffset](/Sources/UI/SwiftUI/Views/ScrollViewWithOffset/ScrollViewWithOffset.swift) | all                                                    | ScrollView that expose offset as we scroll                                  |
| [SimpleColorPicker](/Sources/UI/SwiftUI/Views/SimpleColorPicker/SimpleColorPicker.swift)          | macOS                                                  | Wrapper for NSColorWell component                                           |

| View Modifiers                                                                            | Platform |                                                                                            |
| :---------------------------------------------------------------------------------------- | :------- | :----------------------------------------------------------------------------------------- |
| [MeasureSizeModifier](/Sources/UI/SwiftUI/View%20Modifiers/MeasureSizeModifier.swift)     | all      | A modifier to return size of the underlying view                                           |
| [OnFirstAppearModifier](/Sources/UI/SwiftUI/View%20Modifiers/OnFirstAppearModifier.swift) | all      | Similar to the `OnAppear` modifier, but only runs once per view lifecycle                  |
| [PhotoPickerModifier](/Sources/UI/SwiftUI/View%20Modifiers/PhotoPickerModifier.swift)     | iOS      | Easily add photo or camera picker to the view                                              |
| [PinchToZoomModifier](/Sources/UI/SwiftUI/View%20Modifiers/PinchToZoomModifier.swift)     | iOS      | Pinching and zooming in/out with ease                                                      |
| [SquaredModifier](/Sources/UI/SwiftUI/View%20Modifiers/SquaredModifier.swift)             | all      | Make given view squared. This is mostly used with images to properly keep the aspect ratio |
| [TextFieldLimitModifer](/Sources/UI/SwiftUI/View%20Modifiers/TextFieldLimitModifer.swift) | all      | This modifier adds an upper bound text length limitation to the TextField                  |

| Extensions                                                                   |
| :--------------------------------------------------------------------------- |
| [AnyTransition](/Sources/UI/SwiftUI/Extensions/AnyTransition+PovioKit.swift) |
| [Color](/Sources/UI/SwiftUI/Extensions/Color+PovioKit.swift)                 |
| [Image](/Sources/UI/SwiftUI/Extensions/Image+PovioKit.swift)                 |
| [Text](/Sources/UI/SwiftUI/Extensions/Text+PovioKit.swift)                   |
| [View](/Sources/UI/SwiftUI/Extensions/View+PovioKit.swift)                   |
