# SendBird iOS Sample
![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)
![Languages](https://img.shields.io/badge/language-Objective--C%20%7C%20Swift-orange.svg)

## Introduction

[SendBird](https://sendbird.com) provides the chat API and SDK for your app enabling real-time communication among your users. These samples introduce various applications based on SendBird SDK. Refer to the following applications.
- [Swift Basic Sample](#Swift-Basic-Sample): The project is a sample application composed of common chat features. You can make various channels(group channel and open channel) and send(or receive) messages in the sample. This sample is written in Swift with [SendBird SDK](https://github.com/sendbird/sendbird-ios-framework).
- [Objective-C Basic Sample](#Objective-C-Basic-Sample): The project is a sample application composed of common chat features. You can make various channels(group channel and open channel) and send(or receive) messages in the sample. This sample is written in Objective-C with [SendBird SDK](https://github.com/sendbird/sendbird-ios-framework).
- [SyncManager Sample](#SyncManager-Sample): The project is a sample application composed of common chat features, especially local cache. This sample saves group channels and messages of SendBird in the local database to allow caching and faster data loading. This sample is written in Swift with [SendBird SyncManager SDK](https://github.com/sendbird/sendbird-syncmanager-ios) and [SendBird SDK](https://github.com/sendbird/sendbird-ios-framework). You can learn more about SyncManager from [SyncManager document](https://docs.sendbird.com/ios/sync_manager_getting_started).
- [SendBird UIKit Sample](#sendbird-uikit-sampleswift-only): The project is a sample application composed of common chat features. You can see SendBird's chat service based on SendBird UIKit just by running the sample without any special action. This sample is written in Swift with [SendBird UIKit](https://github.com/sendbird/sendbird-uikit-ios) and [SendBird SDK](https://github.com/sendbird/sendbird-ios-framework). You can learn more about SendBird UIKit from [SendBird UIKit document](https://docs.sendbird.com/ios/ui_kit_getting_started).
- [Legacy Basic Sample](#Legacy-Basic-Sample): The legacy project is a sample application composed of common chat features. We recommend you to use upper new projects. We don't support this sample anymore.

## Quick Start

### [Swift Basic Sample](https://github.com/sendbird/SendBird-iOS-Swift/tree/2e03a93c08b4a119b4f5e18965a5dc087d050ca1)
This sample is linked with git submodule. You can clone the prject directly in [the Swift basic sample submodule repository](https://github.com/sendbird/SendBird-iOS-Swift). Or you can pull it using submodule command after clone this git repository.
```
// clone this repository
git clone git@github.com:sendbird/SendBird-iOS.git  

// clone only Swift basic sample
git submodule update --init ./basic/Swift

// Or you can clone all submodule's repositories
git submodule update --init --recursive    
```

### [Objective-C Basic Sample](https://github.com/sendbird/SendBird-iOS-ObjectiveC/tree/74aca144f3c215ce185e96173620ef5bbf850d99)
This sample is linked with git submodule. You can clone the prject directly in [the Objective-C basic sample submodule repository](https://github.com/sendbird/SendBird-iOS-ObjectiveC). Or you can pull it using submodule command after clone this git repository.
```
// clone this repository
git clone git@github.com:sendbird/SendBird-iOS.git  

// clone only Objective-C basic sample
git submodule update --init ./basic/Objective-C

// Or you can clone all submodule's repositories
git submodule update --init --recursive    
```

### [SyncManager Sample(Swift only)](https://github.com/sendbird/SendBird-iOS/tree/master/syncmanager)
This sample is linked with git submodule. You can clone the project directly in [the Swift SyncManager sample submodule repository](https://github.com/sendbird/SyncManager-iOS-Swift). Or you can pull it using submodule command after this git repository.
```
// clone this repository
git clone git@github.com:sendbird/SendBird-iOS.git

// clone only Swift SyncManager sample
git submodule update --init ./syncmanager/SyncManager-Swift

// Or you can clone all submodule's repositories
git submodule update --init --recursive    
```

### [SendBird UIKit Sample(Swift only)](https://github.com/sendbird/SendBird-iOS/tree/master/uikit)
This sample is linked with git submodule. You can clone the project directly in [the Swift SendBird UIKit sample submodule repository](https://github.com/sendbird/UIKit-iOS-Swift). Or you can pull it using submodule command after this git repository.
```
// clone this repository
git clone git@github.com:sendbird/SendBird-iOS.git

// clone only Swift SyncManager sample
git submodule update --init ./uikit/Swift

// Or you can clone all submodule's repositories
git submodule update --init --recursive    
```

### [Legacy Basic Sample](https://github.com/sendbird/SendBird-iOS/tree/master/basic/old)
You can use [swift](https://github.com/sendbird/SendBird-iOS/tree/master/basic/old/sample-swift) and [objective-C](https://github.com/sendbird/SendBird-iOS/tree/master/basic/old/sample-objc) projects in [the legacy basic sample directory](https://github.com/sendbird/SendBird-iOS/tree/master/basic/old) after clone the repository. 
```
// clone this repository
git clone git@github.com:sendbird/SendBird-iOS.git  
```

## Swift 2.3 support

* Swift 2.3 -> `swift-2.3-sample` directory in `v3-old` branch

## Access to Version 2

You can check out `v2` branch instead of `master` branch to download version 2 samples.
