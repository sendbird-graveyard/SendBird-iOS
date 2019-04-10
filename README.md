# SendBird iOS Sample
![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)
![Languages](https://img.shields.io/badge/language-Objective--C%20%7C%20Swift-orange.svg)

## Introduction

[SendBird](https://sendbird.com) provides the chat API and SDK for your app enabling real-time communication
among your users. These samples introduce various applications based on SendBird SDK. Refer to the following applications.
- [Swift Basic Sample](#Swift-Basic-Sample): The project is a sample application composed of common chat features. You can make various channels(group channel, open channel) and send(or receive) messages in the sample. This sample is written with swift and is based on [SendBird SDK](https://github.com/smilefam/sendbird-ios-framework).
- [Objective-C Basic Sample](#Objective-C-Basic-Sample): The project is a sample application composed of common chat features. You can make various channels(group channel, open channel) and send(or receive) messages in the sample. This sample is written with objective-C and is based on [SendBird SDK](https://github.com/smilefam/sendbird-ios-framework).
- [SyncManager Sample](#SyncManager-Sample): The project is a sample application composed of common chat features, especially local cache. This sample saves SendBird data in the device database to allow caching and faster data loading. We provides the same project in two languages, swift and objective-C. And the sample is based on [SendBird SyncManager SDK](https://github.com/smilefam/sendbird-syncmanager-ios) as well as [SendBird SDK](https://github.com/smilefam/sendbird-ios-framework). You can learn more about syncmanager from [SyncManager sample's ReadMe](https://github.com/smilefam/SendBird-iOS/blob/master/syncmanager/README.md)
- [Legacy Basic Sample](#Legacy-Basic-Sample): The legacy project is a sample application composed of common chat features. We recommend you to use upper new projects. We don't support this sample anymore.

## Quick Start

### [Swift Basic Sample](https://github.com/smilefam/SendBird-iOS-Swift/tree/2e03a93c08b4a119b4f5e18965a5dc087d050ca1)
This sample is linked with git submodule. You can clone the prject directly in [the swift basic sample submodule repository](https://github.com/smilefam/SendBird-iOS-Swift/tree/2e03a93c08b4a119b4f5e18965a5dc087d050ca1). Or you can pull by submodule command after clone this git repository.
```
// clone this repository
git clone git@github.com:smilefam/SendBird-iOS.git  

// clone only swift basic sample
git submodule update --init ./basic/Swift

// Or you can clone all submodule's repositories
git submodule update --init --recursive    
```

### [Objective-C Basic Sample](https://github.com/smilefam/SendBird-iOS-ObjectiveC/tree/74aca144f3c215ce185e96173620ef5bbf850d99)
This sample is linked with git submodule. You can clone the prject directly in [the objective-c basic sample submodule repository](https://github.com/smilefam/SendBird-iOS-ObjectiveC/tree/74aca144f3c215ce185e96173620ef5bbf850d99). Or you can pull by submodule command after clone this git repository.
```
// clone this repository
git clone git@github.com:smilefam/SendBird-iOS.git  

// clone only swift basic sample
git submodule update --init ./basic/Objective-C

// Or you can clone all submodule's repositories
git submodule update --init --recursive    
```

### [SyncManager Sample](https://github.com/smilefam/SendBird-iOS/tree/master/syncmanager)
You can use [swift](https://github.com/smilefam/SendBird-iOS/tree/master/syncmanager/swift) and [objective-C](https://github.com/smilefam/SendBird-iOS/tree/master/syncmanager/objc) projects in [the syncmanager sample directory](https://github.com/smilefam/SendBird-iOS/tree/master/syncmanager) after clone the repository. 
```
// clone this repository
git clone git@github.com:smilefam/SendBird-iOS.git  
```

### [Legacy Basic Sample](https://github.com/smilefam/SendBird-iOS/tree/master/basic/old)
You can use [swift](https://github.com/smilefam/SendBird-iOS/tree/master/basic/old/sample-swift) and [objective-C](https://github.com/smilefam/SendBird-iOS/tree/master/basic/old/sample-objc) projects in [the legacy basic sample directory](https://github.com/smilefam/SendBird-iOS/tree/master/basic/old) after clone the repository. 
```
// clone this repository
git clone git@github.com:smilefam/SendBird-iOS.git  
```

## Swift 2.3 support

* Swift 2.3 -> `swift-2.3-sample` directory in `v3-old` branch

## Access to Version 2

You can check out `v2` branch instead of `master` branch to download version 2 samples.
