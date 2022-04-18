## Migration Guides

### Migrating from versions < 2.0.0
* New product `PovioKitUI` is introduced. In order to use it, please re-intall dependency and select it from product selection list.
* Method `asJson` inside `PovioKitNetworking` product was marked as deprecated. Please stop using it soon.
* Deprecated method inside `PovioKitPromise` were removed. 

### Migrating from versions < 1.3.0
* PromiseKit requires some changes due to deprecated methods. You'll need to rename them in order to avoid warnings. `chain` was renamed to `flatMap`, `observe` was renamed to `finally`, `onFailure` was renamed to `catch`, `chainError` was renamed to `flatMapError`, `onSuccess` was renamed to `then`.
