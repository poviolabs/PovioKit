#  Sign In with Apple

Sign In with Apple helper utility. It can be used together with custom backend implementation or with integration to external services like Firebase Auth.

## Example

`SignInWithApple` can be used in applications where such type of sign in is required.

```swift
let signInWithApple = SignInWithApple()
signInWithApple.delegate = self

...

// check the current state
signInWithApple.checkAuthorizationState()

...

// start the authorization flow
signInWithApple.authorizeSignIn()

...

// reset state
signInWithApple.resetAuthorizationState()
```
