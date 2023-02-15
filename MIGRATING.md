## Migration Guides

### Migration from versions < 3.0.0
* [Core] The main package was renamed from `PovioKit` to `PovioKitCore`. You'll need to make a few changes in order to make this work:
  * Remove library `PovioKit` under "Frameworks, Libraries, and Embedded Content" in Xcode and add a `PovioKitCore`.
  * Replace all `import PovioKit` with `import PovioKitCore` in code.

### Migration from versions < 2.0.0
* [Networking] File `OAuthRequestInterceptor` has been completely removed due to some critical issues. We encourage you to migrate to Alamofire's `Authenticator` protocol. Instructions can be found [here](Resources/Networking/AlamofireNetworkClient#oauth). Deprecated methods have also been removed.
* [Package] The minimum supported version of iOS is 13. If you still support iOS 12, please evaluate this update.
* [DataSource] Protocols have been deprecated in favor or diffable data source.
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
