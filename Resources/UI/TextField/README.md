#  TextField

A generic-customizable textfield with optional validation.
Includes `RuleValidatable` protocol to validate input and show appropriate error message.

### Example

Usage:  
1. Create textfield without validation
`let textField = TextField()`

2. Create textfield with validation
```
struct RequiredRule: RuleValidatable {
  let error: String
  
  init(error: String = "Need input") {
    self.error = error
  }
  
  func validate(_ input: String?) -> Bool {
    input.noneIfEmpty != .none
  }
}
```


Create rule and attach it to textfield on initial creation:
```
lazy var requiredRule = RequiredRule()

let validatableTextField = TextField(with: requiredRule)

```

Rule can also be attached later:
```
let requiredRule = RequiredRule()

let validatableTextField = TextField()

...

validatableTextField.set(rule)
```

To check if textField is valid:
```
guard validatableTextField.isValid else { return }
```

Validation will be triggered when `validatableTextField.isValid` is called and if validation doesn't pass then the error message will automatically be shown under the textfield.
