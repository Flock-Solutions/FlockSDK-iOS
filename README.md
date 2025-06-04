# FlockSDK-iOS

FlockSDK-iOS is the official iOS SDK for integrating [Flock](https://www.withflock.com) referral and rewards into your iOS apps. Flock helps you effortlessly enable customer-driven growth by building powerful referral programs in minutes.

## Features

- Identify and track customers in your app.
- Easily show Flock referral experiences as modals or full screen.
- Handle events such as close, success, and invalid directly in your app.
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
.package(url: "https://github.com/Flock-Solutions/FlockSDK-iOS.git", from: "1.0.0")
```

Then add `"FlockSDK"` as a dependency for your target.

## Usage

### 1\. Configure the SDK

Call `Flock.initialize` once, for example in your `AppDelegate` or early in your app's startup:

```swift
import FlockSDK

try? Flock.initialize(
    publicAccessKey: "<YOUR_FLOCK_PUBLIC_KEY>",
    environment: .production // or .test
)
```

### 2\. Identify Your User

Identify the current user (after login or at app start):

```swift
try? Flock.shared.identify(
    externalUserId: "<USER_ID_IN_YOUR_APP>",
    email: "user@example.com",
    name: "Alice Smith"
)
```

### 3\. Show a Flock Page

Present the referral page anywhere in your app:

```swift
import FlockSDK

try? Flock.shared.openPage(
    type: "referrer", // Or "invitee" or "invitee?state=success"
    onClose: {
        // Called when closed
    },
    onSuccess: {
        // Called for success event
    },
    onInvalid: {
        // Called for invalid event
    }
)
```

You can set `style: .fullscreen` for a fullscreen experience.

## Support

If you run into issues or need support, open an [issue](https://github.com/Flock-Solutions/FlockSDK-iOS/issues) or contact us at <support@withflock.com>.

## License

MIT License

-----

Happy referring 🚀
