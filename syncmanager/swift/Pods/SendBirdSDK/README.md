# [SendBird](https://sendbird.com) - Messaging and Chat API for Mobile Apps and Websites
[SendBird](https://sendbird.com) provides the chat API and SDK for your app enabling real-time communication among your users.

[![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)](https://cocoapods.org/pods/SendBirdSDK)
[![Languages](https://img.shields.io/badge/language-Objective--C%20%7C%20Swift-orange.svg)](https://github.com/smilefam/sendbird-ios-framework)
[![CocoaPods](https://img.shields.io/badge/pod-v3.0.130-green.svg)](https://cocoapods.org/pods/SendBirdSDK)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Commercial License](https://img.shields.io/badge/license-Commercial-brightgreen.svg)](https://github.com/smilefam/sendbird-ios-framework/blob/master/LICENSE.md)

## Documentation
https://docs.sendbird.com/

## Install SendBird Framework from CocoaPods

Add below into your Podfile on Xcode.

```
platform :ios, '8.0'
use_frameworks!

target YOUR_PROJECT_TARGET do
  pod 'SendBirdSDK'
end
```

Install SendBird Framework through CocoaPods.

```
pod install
```

Now you can see installed SendBird framework by inspecting YOUR_PROJECT.xcworkspace.

## Install SendBird Framework from Carthage

1. Add `github "smilefam/sendbird-ios-framework"` to your `Cartfile`.
2. Run `carthage update`.
3. Go to your Xcode project's "General" settings. Open `<YOUR_XCODE_PROJECT_DIRECTORY>/Carthage/Build/iOS` in Finder and drag `SendBirdSDK.framework` to the "Embedded Binaries" section in Xcode. Make sure `Copy items if needed` is selected and click `Finish`.

## SyncManager
`SyncManager` is a support add-on for [SendBird SDK](https://github.com/smilefam/sendbird-ios-framework). Major benefits of `SyncManager` are,  
  
 * Local cache integrated: store channel/message data in local storage for fast view loading.  
 * Event-driven data handling: subscribe channel/message event like `insert`, `update`, `remove` at a single spot in order to apply data event to view.  
  
Check out [iOS Sample with SyncManager](https://github.com/smilefam/SendBird-iOS-LocalCache-Sample) which is same as [iOS Sample](https://github.com/smilefam/SendBird-iOS) with `SyncManager` integrated.    
For more information about `SyncManager`, please refer to [SyncManager README](https://github.com/smilefam/SendBird-iOS-LocalCache-Sample/blob/master/README.md). 