# InAppPurchase

Helper for implementation of InApp puchase mehanism in the app.
> Important: InAppPurchase is supported from iOS 15.0

## Overview  

A InAppPurchase is initialized with the array of ``IAPPlan`` (eg. ["com.test.plan1", "com.test.plan2"]). Identifier array values should match ones from the AppStore and/or ``configuration.storekit`` file. 

See: [AppStore setup](#appstore-setup) and [StoreKit configuration file](#test-locally-with-storekit-configuration-file) for more info.

> Note: Initialize InAppPurchase as close to the app launch as possible, so you don't miss any transactions.

### Typealias:
- InAppPurchase plan:
``` swift
typealias IAPPlan = String
```
- InAppPurchase receipt:
``` swift
typealias IAPReceipt = String
```
### Public methods:
- Purchase plan with options:
``` swift
func purchase(plan: IAPPlan, options: Set<Product.PurchaseOption> = []) async -> Result<Transaction, InAppPurchaseError>
```
- Check if plan is purchased:
``` swift
func isPlanPurchased(_ plan: IAPPlan) async -> Result<Bool, InAppPurchaseError>
```
- Force call to restore purchases (this should be called in last resort since restore is done automatically):
``` swift
func restorePurchases() async -> Result<Void, InAppPurchaseError>
```
- Validate receipt:
``` swift
func validateReceipt() -> Result<IAPReceipt, InAppPurchaseError>
```
--- 
## AppStore setup
The first step to adding in-app purchases to an app is to create the products in [App Store Connect](https://developer.apple.com/app-store-connect/). 

There are two different sections for creating and managing in-app purchases. The first section is “In-App Purchases” and the second is the “Subscriptions”. “In-App Purchases” is for consumables and non-consumables, while “Subscriptions” is for auto-renewable and non-renewing subscriptions. Subscriptions have been separated because their configuration is more complex than consumables and non-consumables.

### App Store Connect requirements

There are a few administrative items that must be completed before your app can sell in-app purchases:
- Setup bank information
- Sign Paid App agreement

### Create subscriptions (auto-renewable and non-renewing)
1. Go to “Subscriptions”
2. Create a “Subscription Group”
3. Add a localization for the “Subscription Group”
4. Create new subscription (reference name and product id)
5. Fill out all metadata (duration, price, localization, review information)

### Create consumables and non-consumables
1. Go to “In-app Purchases”
2. Create a new in-app purchase
3. Select the type (consumable or non-consumable) and set reference name and product id
4. Fill out all metadata (price, localization, review information)

## Test locally with StoreKit configuration file
The entire in-app purchase workflow can be done and tested by using a StoreKit configuration file. When created, XCode uses this local data when your app calls StoreKit APIs. Check [documentation](https://developer.apple.com/documentation/xcode/setting-up-storekit-testing-in-xcode) for more info.

### Create the file
1. Launch Xcode, then choose File > New > File.
2. Search for “storekit” in the Filter search field.
3. Select “StoreKit Configuration File”
4. Name it, check “Sync this file with an app in App Store Connect”, and save it.

### Add products (optional)

Xcode 14 added the ability to sync this file with an app in App Store Connect. 
If you want to test with other product types or duration (or using XCode version lower than 14), you can add in-app purchases manually: 
1. Click “+” in the bottom left corner in the StoreKit Configuration File editor in Xcode.
2. Select a type of in-app purchase.
3. Fill out the required fields:
  - Reference name
  - Product ID
  - Price
  - At least one localization

### Enable the StoreKit Configuration File
Simply creating StoreKit Configuration File isn’t enough to use it. The StoreKit Configuration File needs to be selected in an Xcode scheme.
1. Click scheme and select “Edit scheme.”
2. Go to Run > Options.
3. Select a value for “StoreKit Configuration.”


## Examples
### Init
``` swift
@main
class AppDelegate: UIResponder {
  private(set) var inAppPurchase: InAppPurchase?
}

extension AppDelegate: UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Identifier array values should match ones from the configuration.storekit file
    inAppPurchase = InAppPurchase(identifiers:  ["com.test.plan1", "com.test.plan2", "com.test.plan3", "com.test.plan4"])
    return true
  }
}
```

### Purchase plan
``` swift
Task {
  let result = await inAppPurchase.purchase(plan: "com.test.plan1")
  switch result {
    case .success(let transaction):
      print("purchase plan success with transaction: \(transaction.productID)")
    case .failure(let error):
      print("purchase plan failure with error: \(error.localizedDescription)")
  }
}
```

### Check if plan is purchased
``` swift
Task {
  let planId = "com.test.plan1"
  let result = await inAppPurchase.isPlanPurchased(planId)
  switch result {
  case .success(let isPurchased):
    if isPurchased {
      print("plan \(planId) is purchased!")
    }
  case .failure(let error):
    print("error in checking if the plan \(planId) is purchased: \(error.localizedDescription)")
  }
}
```

### Restore purchases
``` swift
Task {
  let result = await inAppPurchase.restorePurchases()
  switch result {
  case .success():
    print("Restore purchases success")
  case .failure(let error):
    print("Restore purchases failed with error: \(error.localizedDescription)")
  }
}
```

### Validate receipt
``` swift
Task {
  let result = await inAppPurchase.validateReceipt()
  switch result {
  case .success(let receipt):
    print("Receipt valid: \(receipt)")
  case .failure(let failure):
    print("Receipt validation failed with error: \(error.localizedDescription)")
  }
}
```

## Source code
You can find source code [here](/Sources/Core/Utilities/InAppPurchase).