## Migration Guides

### Migration from versions < 3.0.0
* [Auth] All Auth products are removed from the PovioKit package and effectivelly moved to a standalone repo https://github.com/poviolabs/PovioKitAuth. In order to continue using Auth products, install the new package `PovioKitAuth` package from the given repo url. 

### Migration from versions < 2.3.0
* [Core] The main package was renamed from `PovioKit` to `PovioKitCore`. You'll need to make a few changes in order to make this work:
  * Remove library `PovioKit` under "Frameworks, Libraries, and Embedded Content" in Xcode and add a `PovioKitCore`.
  * Replace all `import PovioKit` with `import PovioKitCore` in code.
* [Core] Deprecated DataSource protocols and SignInWithApple utility have been removed.

### Migration from versions < 2.2.0
* [Core] Deprecated DataSource protocols and SignInWithApple utility have been removed.

### Migration from versions < 2.0.0
* [Networking] File `OAuthRequestInterceptor` has been completely removed due to some critical issues. We encourage you to migrate to Alamofire's `Authenticator` protocol. Instructions can be found [here](Resources/Networking/AlamofireNetworkClient#oauth). Deprecated methods have also been removed.
* [Package] The minimum supported version of iOS is 13. If you still support iOS 12, please evaluate this update.
* [Core] DataSource protocols have been deprecated in favor or diffable data source.
* [UI] Removed deprecated methods.

### Migration from versions < 1.4.1
* [Networking] File `OAuthRequestInterceptor` has been deprecated due to some critical issues. We encourage you to migrate to Alamofire's `Authenticator` protocol. Instructions can be found [here](Resources/Networking/AlamofireNetworkClient#oauth).

### Migration from versions < 1.4.0
* [UI] New product `PovioKitUI` is introduced. In order to use it, please re-intall dependency and select it from product selection list.
* [Networking] Method `asJson` was marked as deprecated. Please stop using it soon.
* [PromiseKit] Removed deprecated methods.

### Migrating from versions < 1.3.1
* [Networking] OAuthStorage protocol now accepts `OAuthContainer` only instead of separate values for `accessToken` and `refreshToken`. Change your implementation accordingly.

### Migrating from versions < 1.3.0
* [PromiseKit] Changes required due to deprecated methods. You'll need to rename them in order to avoid warnings. `chain` was renamed to `flatMap`, `observe` was renamed to `finally`, `onFailure` was renamed to `catch`, `chainError` was renamed to `flatMapError`, `onSuccess` was renamed to `then`.
