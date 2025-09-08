# FlockSDK-iOS

FlockSDK-iOS is the official iOS SDK for integrating [Flock](https://www.withflock.com) referral and rewards into your iOS apps. Flock helps you effortlessly enable customer-driven growth by building powerful referral programs in minutes.

## Features

- Identify and track customers in your app.
- Trigger checkpoints to show Flock experiences at specific moments in your user journey.
- Navigate within existing web views or create new placements.
- Handle events such as close, success, and invalid directly in your app.
- Modern Swift builder pattern API for easy configuration.
- Built with Swift and officially supported by the Flock team.

## Requirements

- iOS 14.0 or later
- Swift 5.7 or later
- Xcode 14 or later

## Installation

### Swift Package Manager (Recommended)

Add to your Xcode project via `File > Add Packages...` and use this repo's URL:
<https://github.com/Flock-Solutions/FlockSDK-iOS.git>

```swift
.package(url: "https://github.com/Flock-Solutions/FlockSDK-iOS.git", from: "0.2.0")
```

Then add `"FlockSDK"` as a dependency for your target.

## Usage

### 1\. Configure the SDK

Call `Flock.initialize` once, for example in your `AppDelegate` or early in your app's startup:

```swift
import FlockSDK

try? Flock.shared.initialize(
    publicAccessKey: "<YOUR_FLOCK_PUBLIC_KEY>",
    environment: .production // or .test
)
```

### 2\. Identify Your User

Identify the current user (after login or at app start):

```swift
import FlockSDK

try? Flock.shared.identify(
    externalUserId: "<USER_ID_IN_YOUR_APP>",
    email: "user@example.com",
    name: "Alice Smith",
    customProperties: [
        "plan": .string("pro"),
        "age": .int(29),
        "lifetimeValue": .double(1234.56),
        "notificationsEnabled": .bool(true),
        "nickname": .null
    ]
)
```

### 3\. Trigger Checkpoints

Trigger checkpoints to show Flock experiences at specific moments in your user journey:

```swift
import FlockSDK

// Simple checkpoint trigger
Flock.shared.checkpoint("refer_button_clicked").trigger()

Flock.shared.checkpoint("refer_button_clicked")
    .onClose {
        print("Checkpoint closed")
    }
    .onSuccess { flock in
        print("Checkpoint succeeded")
    }
    .onInvalid { flock in
        print("Checkpoint invalid")
    }
    .trigger()

// Checkpoint with navigation in success callback (e.g., show success screen)
Flock.shared.checkpoint("user_onboarded")
    .onSuccess { flock in
        // Navigate to success screen when invitee enters valid referral code
        flock.checkpoint("referral_succeeded").navigate().trigger()
    }
    .trigger()
```

## Support

If you run into issues or need support, open an [issue](https://github.com/Flock-Solutions/FlockSDK-iOS/issues) or contact us at <support@withflock.com>.

## License

MIT License

-----

Happy referring 🚀
