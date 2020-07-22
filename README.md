# Sendbird iOS samples
![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)
![Languages](https://img.shields.io/badge/language-Objective--C%20%7C%20Swift-orange.svg)

## Introduction

[Sendbird](https://sendbird.com) provides the chat API and SDK for your app, enabling real-time communication among the users. Here are various samples built using Sendbird Chat SDK.

- [Chat Swift sample](#chat-swift-sample) has core chat features. Group channel and open channel are the two main channel types in which you can create various subtypes where users can send and receive messages. This sample is written in Swift with [Sendbird Chat SDK](https://github.com/sendbird/sendbird-ios-framework).

- [Chat Objective-C sample](#chat-objective-c-sample) has core chat features. Group channel and open channel are the two main channel types in which you can create various subtypes where users can send and receive messages. This sample is written in Objective-C with [Sendbird Chat SDK](https://github.com/sendbird/sendbird-ios-framework).

- [UIKit Swift sample](#uikit-sampleswift-only) is a user interface development kit that allows easy and fast integration of core chat features for new or pre-existing client apps. UI components can be fully customized with ease to expedite the roll-out of your client app’s in-app chat service. This sample is written in Swift with [Sendbird UIKit](https://github.com/sendbird/sendbird-uikit-ios) and [Sendbird Chat SDK](https://github.com/sendbird/sendbird-ios-framework). Find more about Sendbird UIKit on [Sendbird UIKit document](https://docs.sendbird.com/ios/ui_kit_getting_started).

- [SyncManager Swift sample](#syncmanager-sampleswift-only) is equipped with a local cache along with core chat features. For faster data loading and caching, the sample synchronizes with the Sendbird server and saves a list of group channels and the messages within the local cache into your client app. This sample is written in Swift with [Sendbird SyncManager SDK](https://github.com/sendbird/sendbird-syncmanager-ios) and [Sendbird Chat SDK](https://github.com/sendbird/sendbird-ios-framework). Find more about SyncManager on [Sendbird SyncManager document](https://docs.sendbird.com/ios/sync_manager_getting_started).

## Installation

### [Chat Swift sample](https://github.com/sendbird/SendBird-iOS-Swift/tree/2e03a93c08b4a119b4f5e18965a5dc087d050ca1)

This sample is linked with the git submodule which you can download in two ways. 

A. You can **clone** the project directly from the [Chat Swift sample submodule repository](https://github.com/sendbird/SendBird-iOS-Swift). 

```
// Clone this repository
git clone git@github.com:sendbird/SendBird-iOS.git  

// Clone only Chat Swift sample
git submodule update --init ./basic/Swift
```

B. You can **pull** it by using the **submodule** command after **cloning** the git repository.

```
// Clone all submodule's repositories
git submodule update --init --recursive    
```

### [Chat Objective-C sample](https://github.com/sendbird/SendBird-iOS-ObjectiveC/tree/74aca144f3c215ce185e96173620ef5bbf850d99)

This sample is linked with the git submodule which you can download in two ways. 

A. You can **clone** the prject directly from the [Chat Objective-C sample repository](https://github.com/sendbird/SendBird-iOS-ObjectiveC).

```
// Clone this repository
git clone git@github.com:sendbird/SendBird-iOS.git  

// Clone only Chat Objective-C sample
git submodule update --init ./basic/Objective-C
```

B. You can **pull** it by using the **submodule** command after **cloning** the git repository.

```
// Clone all submodule's repositories
git submodule update --init --recursive    
```

### [UIKit sample (Swift only)](https://github.com/sendbird/SendBird-iOS/tree/master/uikit)

This sample is linked with the git submodule which you can download in two ways. 

A. You can **clone** the project directly from the [UIKit Swift sample repository](https://github.com/sendbird/UIKit-iOS-Swift). Or you can pull it using submodule command after this git repository.

```
// Clone this repository
git clone git@github.com:sendbird/SendBird-iOS.git

// Clone only UIKit swift sample
git submodule update --init ./uikit/Swift
```

B. You can **pull** it by using the **submodule** command after **cloning** the git repository.

```
// Clone all submodule's repositories
git submodule update --init --recursive    
```

### [SyncManager sample (Swift only)](https://github.com/sendbird/SendBird-iOS/tree/master/syncmanager)

This sample is linked with the git submodule which you can download in two ways. 

A. You can **clone** the project directly from the [SyncManager Swift sample repository](https://github.com/sendbird/SyncManager-iOS-Swift).

```
// Clone this repository
git clone git@github.com:sendbird/SendBird-iOS.git

// Clone only SyncManager Swift sample
git submodule update --init ./syncmanager/SyncManager-Swift
```

B. You can **pull** it by using the **submodule** command after **cloning** the git repository.

```
// Clone all submodule's repositories
git submodule update --init --recursive    
```

