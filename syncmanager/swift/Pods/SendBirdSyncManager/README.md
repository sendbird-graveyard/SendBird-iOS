# [SendBird](https://sendbird.com) SyncManager for iOS
[SendBird](https://sendbird.com) SyncManager is a framework that caches and manages channels and messages of [SendBird SDK](https://github.com/smilefam/sendbird-ios-framework). The SyncManager offers an event-based data management so that each view would see a single method by subscribing data event. And it stores the data into database(sqlite) which implements local caching for faster loading.

[![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)](https://cocoapods.org/pods/SendBirdSyncManager)
[![Languages](https://img.shields.io/badge/language-Objective--C%20%7C%20Swift-orange.svg)](https://github.com/smilefam/sendbird-syncmanager-ios)
[![CocoaPods](https://img.shields.io/badge/pod-v1.0.0-green.svg)](https://cocoapods.org/pods/SendBirdSyncManager)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Commercial License](https://img.shields.io/badge/license-Commercial-brightgreen.svg)](https://github.com/smilefam/sendbird-syncmanager-ios/blob/master/LICENSE.md)

## Documentation
https://docs.sendbird.com/ios

## Install SendBird SyncManager Framework from CocoaPods

Add below into your Podfile on Xcode.

```
platform :ios, '8.0'
use_frameworks!

target YOUR_PROJECT_TARGET do
  pod 'SendBirdSyncManager'
end
```

Install SendBird SyncManager Framework through CocoaPods.

```
pod install
```

Update SendBird SyncManager Framework through CocoaPods.

```
pod update SendBirdSyncManager
```

Now you can see installed SendBird framework by inspecting YOUR_PROJECT.xcworkspace.

## Install SendBird Framework from Carthage

1. Add `github "smilefam/sendbird-syncmanager-ios"` to your `Cartfile`.
2. Run `carthage update`.
3. Go to your Xcode project's "General" settings. Open `<YOUR_XCODE_PROJECT_DIRECTORY>/Carthage/Build/iOS` in Finder and drag `SendBirdSyncManager.framework` to the "Embedded Binaries" section in Xcode. Make sure `Copy items if needed` is selected and click `Finish`.

## Sample
Check out [iOS Sample with SyncManager](https://github.com/smilefam/SendBird-iOS/syncmanager/) which is same as iOS Sample with SyncManager integrated.

## Usage

### Initialization
`SBSMSyncManager` is singlton class. And when `SBSMSyncManager` was initialized, a instance for `Database` is set up. So if you want to initialize `Database` as soon as possible, call `setup(_:)` first just after you get a user's ID. we recommend it is in `application(_:didFinishLaunchingWithOptions:)`.
```swift
// AppDelegate.swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    ... // get user's ID    
    SBSMSyncManager.setup(withUserId: userId)
    ...
}
```
```objc
// AppDelegate.m
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ...

    [SBSMSyncManager setupWithUserId:userId];

    ...
}
```

### Collection

`Collection` is a container to manage objects(channels, messages) related to a view. `SBSMChannelCollection` is attached to channel list view contoller and `SBSMMessageCollection` is attached to message list view contoller accordingly. The main purpose of `Collection` is,

- To listen data event and deliver it as view event.
- To fetch data from cache or SendBird server and deliver the data as view event.

To meet the purpose, each collection has event subscriber and data fetcher. Event subscriber listens data event so that it could apply data update into view, and data fetcher loads data from cache or server and sends the data to event handler.

#### Channel Collection
Channel is quite mutable data where chat is actively going - channel's last message and unread message count may update very often. Even the position of each channel is changing drastically since many apps sort channels by the most recent message. For that reason, `SBSMChannelCollection` depends mostly on server sync. Here's the process `SBSMChannelCollection` synchronizes data:

1. It loads channels from cache and the view shows them.
2. Then it fetches the most recent channels from SendBird server and merges with the channels in view.
3. It fetches from SendBird server every time `fetch(_:)` is called in order to view previous channels.

> Note: Channel data sync mechanism could change later.

`SBSMChannelCollection` requires `SBDGroupChannelListQuery` instance of [SendBirdSDK](https://github.com/smilefam/sendbird-ios-framework) as it binds the query into the collection. Then the collection filters data with the query. Here's the code to create new `SBSMChannelCollection` instance.

```swift
// swift
let query: SBDGroupChannelListQuery? = SBDGroupChannel.createMyGroupChannelListQuery()
// ...setup your query here
let channelCollection: SBSMChannelCollection? = SBSMChannelCollection.init(query: query)
```
```objc
// objective-c
SBDGroupChannelListQuery *query = [SBDGroupChannel createMyGroupChannelListQuery];
// ...setup your query here
SBSMChannelCollection *channelCollection = [SBSMChannelCollection collectionWithQuery:query];
```

If the view is closed, which means the collection is obsolete and no longer used, remove collection explicitly.

```swift
// swift
channelCollection.remove()
```
```objc
// objective-c
[channelCollection remove];
```

As aforementioned, `SBSMChannelCollection` provides event handler with delegate. Event handler is named as `SBSMChannelCollectionDelegate` and it receives `SBSMChannelEventAction` and list of `channels` when an event has come. The `SBSMChannelEventAction` is a keyword to notify what happened to the channel list, and the `channel` is a kind of `SBDGroupChannel` instance. You can create an view controller instance and implement the event handler and add it to the collection.

```swift
// swift

// add delegate
channelCollection?.delegate = self

// channel collection delegate
func collection(_ collection: SBSMChannelCollection, didReceiveEvent action: SBSMChannelEventAction, channels: [SBDGroupChannel]) {
    switch (action) {
    case SBSMChannelEventAction.insert:
        // Insert channels on list
        break
    case SBSMChannelEventAction.update:
        // Update channels of list
        break
    case SBSMChannelEventAction.remove:
        // Remove channels of list
        break
    case SBSMChannelEventAction.move:
        // Move channel of list
        break
    case SBSMChannelEventAction.clear:
        // Clear(Remove all) channels
        break
    case SBSMChannelEventAction.none:
        break
    default:
        break
    }
}
```
```objc
// objective-c

// add delegate
channelCollection.delegate = self;

// channel collection delegate
- (void)collection:(SBSMChannelCollection *)collection didReceiveEvent:(SBSMChannelEventAction)action channels:(NSArray<SBDGroupChannel *> *)channels {
    switch (action) {
        case SBSMChannelEventActionInsert: {
            // Insert channels on list
            break;
        }
        case SBSMChannelEventActionUpdate: {
            // Update channels of list
            break;
        }
        case SBSMChannelEventActionRemove: {
            // Remove channels of list
            break;
        }
        case SBSMChannelEventActionMove: {
            // Move channel of list
            break;
        }
        case SBSMChannelEventActionClear: {
            // Clear(Remove all) channels
            break;
        }
        case SBSMChannelEventActionNone:
        default: {
            break;
        }
    }
}
```

And data fetcher. Fetched channels would be delivered to delegate method. fetcher determines the `SBSMChannelEventAction` automatically so you don't have to consider duplicated data in view.

```swift
// swift
channelCollection.fetch(completionHandler: {(error) in
    // This callback is optional and useful to catch the moment of loading ended.
})
```
```objc
// objective-c
[channelCollection fetchWithCompletionHandler:^(SBDError * _Nullable error) {
    // This callback is optional and useful to catch the moment of loading ended.
}];
```

#### Message Collection
Message is relatively static data and SyncManager supports full-caching for messages. `SBSMMessageCollection` conducts background synchronization so that it synchronizes all the messages until it reaches to the first message. Background synchronization does NOT affect view directly but store for local cache. For view update, explicitly call `fetch(_:_:)` with direction which fetches data from cache and sends the data into collection handler.

Background synchronization ceases if the synchronization is done or synchronization request is failed.

> Note: Background synchronization run in background thread.

For various viewpoint(`viewpointTimestamp`) support, `SBSMMessageCollection` sets a timestamp when to fetch messages. The `viewpointTimestamp` is a timestamp to start background synchronization in both previous and next direction (and also the point where a user sees at first). Here's the code to create `SBSMMessageCollection`.

```swift
// swift
let filter: SBSMMessageFilter = SBSMMessageFilter.init(messageType: SBDMessageTypeFilter, customType: customTypeFilter, senderUserIds: senderUserIdsFilter)
let viewpointTimestamp: Int64 = getLastReadTimestamp()
// or LONG_LONG_MAX if you want to see the most recent messages

let messageCollection: SBSMMessageCollection? = SBSMMessageCollection.init(channel: channel, filter: filter, viewpointTimestamp: viewpointTimestamp)
```
```objc
// objective-c
SBSMMessageFilter *filter = [SBSMMessageFilter filterWithMessageType:SBDMessageTypeFilter customType:customtypeFilter senderUserIds:senderUserIdsFilter];
long long viewpointTimestamp = getLastReadTimestamp();
// or LONG_LONG_MAX if you want to see the most recent messages

SBSMMessageCollection *messageCollection = [SBSMMessageCollection collectionWithChannel:self.channel filter:filter viewpointTimestamp:LONG_LONG_MAX];
```

You can dismiss collection when the collection is obsolete and no longer used.

```swift
// swift
messageCollection.remove()
```
```objc
[messageCollection remove];
```

`SBSMMessageCollection` has event handler for delegate that you can implement and add to the collection. Event handler is named as `SBSMMessageCollectionDelegate` and it receives `SBSMMessageEventAction` and list of `messages` when an event has come. The `SBSMMessageEventAction` is a keyword to notify what happened to the message, and the `message` is a kind of `SBDBaseMessage` instance of [SendBird SDK](https://github.com/smilefam/sendbird-ios-framework).

```swift
// swift

// add delegate
messageCollection.delegate = self

// message collection delegate
func collection(_ collection: SBSMMessageCollection, didReceiveEvent action: SBSMMessageEventAction, messages: [SBDBaseMessage]) {
    switch action {
    case SBSMMessageEventAction.insert:
        self.chattingView?.insert(messages: messages, completionHandler: nil)
        break
    case SBSMMessageEventAction.update:
        self.chattingView?.update(messages: messages, completionHandler: nil)
        break
    case SBSMMessageEventAction.remove:
        self.chattingView?.remove(messages: messages, completionHandler: nil)
        break
    case SBSMMessageEventAction.clear:
        self.chattingView?.clearAllMessages(completionHandler: nil)
        break
    case SBSMMessageEventAction.none:
        break
    default:
        break
    }
}
```
```objc
// objective-c

// add delegate
messageCollection.delegate = self;

// message collection delegate
- (void)collection:(SBSMMessageCollection *)collection didReceiveEvent:(SBSMMessageEventAction)action messages:(NSArray<SBDBaseMessage *> *)messages {
    switch (action) {
        case SBSMMessageEventActionInsert: {
            //
            break;
        }
        case SBSMMessageEventActionUpdate : {
            //
            break;
        }
        case SBSMMessageEventActionRemove: {
            //
            break;
        }
        case SBSMMessageEventActionClear: {
            //
            break;
        }
        case SBSMMessageEventActionNone:
        default:
            break;
    }
}
```

`SBSMMessageCollection` has data fetcher by direction: `SBSMMessageDirection.previous` and `SBSMMessageDirection.next`. It fetches data from cache only and never request to server directly. If no more data is available in a certain direction, it wait for the background synchronization internally and fetches the synced messages right after the synchronization progresses.

```swift
// swift
messageCollection.fetch(in: SBSMMessageDirection.previous, completionHandler: { (error) in
  // Fetching from cache is done
})
messageCollection.fetch(in: SBSMMessageDirection.next, completionHandler: { (error) in
  // Fetching from cache is done
})
```
```objc
// objective-c
[messageCollection fetchInDirection:SBSMMessageDirectionPrevious completionHandler:^(SBDError * _Nullable error) {
  // Fetching from cache is done
}];
[messageCollection fetchInDirection:SBSMMessageDirectionNext completionHandler:^(SBDError * _Nullable error) {
  // Fetching from cache is done
}];
```

Fetched messages would be delivered to delegate. fetcher determines the `SBSMMessageEventAction` automatically so you don't have to consider duplicated data in view.

#### Handling uncaught messages

SyncManager listens message event such as `channel(_:didReceive:)` and `channel(_:didUpdate:)`, and applies the change automatically. But they would not be called if the message is sent by `currentUser`. You can keep track of the message by calling related function when the `currentUser` sends or updates message. `SBSMMessageCollection` provides methods to apply the message event to collections.

```swift
// swift 

// call collection.appendMessage() after sending message
var previewMessage: SBDUserMessage?
channel.sendUserMessage(with: params, completionHandler: { (theMessage, theError) in
    guard let message: SBDUserMessage = theMessage, let _: SBDError = theError else {
        // delete preview message if sending message fails
        messageCollection.deleteMessage(previewMessage)
        return
    }
    
    messageCollection.appendMessage(message)
})

if let thePreviewMessage: SBDUserMessage = previewMessage {
    messageCollection.appendMessage(thePreviewMessage)
}


// call collection.updateMessage() after updating message
channel.sendUserMessage(with: params, completionHandler: { (theMessage, error) in
    guard let message: SBDUserMessage = theMessage, let _: SBDError = error else {
        return
    }
    
    messageCollection.updateMessage(message)
})
```
```objc
// objective-c 

// call [collection appendMessage:] after sending message
__block SBDUserMessage *previewMessage = [channel sendUserMessageWithParams:params completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
    if (error != nil) {
        [messageCollection deleteMessage:previewMessage];
        return;
    }
    
    [self.messageCollection appendMessage:userMessage];
}];

if (previewMessage.requestId != nil) {
    [messageCollection appendMessage:previewMessage];
}


// call [collection updateMessage:] after updating message
[channel sendUserMessageWithParams:params completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {    
    [self.messageCollection updateMessage:userMessage];
}];
```

It works only for messages sent by `currentUser` which means the message sender should be `currentUser`.

### Connection Lifecycle

You should let SyncManager start synchronization after connect to SendBird. Call `resumeSynchronization()` on connection, and `pauseSynchronization()` on disconnection. Here's the code:

```swift
// swift
let manager: SBSMSyncManager = SBSMSyncManager()
manager.resumeSynchronize()

let manager: SBSMSyncManager = SBSMSyncManager()
manager.pauseSynchronize()
```
```objc
// objective-c
SBSMSyncManager *manager = [SBSMSyncManager manager];
[manager resumeSynchronize];

SBSMSyncManager *manager = [SBSMSyncManager manager];
[manager pauseSynchronize];
```

The example below shows relation of connection status and resume synchronization. 

```swift
// swift

// Request Connect to SendBird
SBDMain.connect(withUserId: userId) { (user, error) in
    if let theError: NSError = error {
        return
    }
    
    let manager: SBSMSyncManager = SBSMSyncManager()
    manager.resumeSynchronize()
}

// SendBird Connection Delegate
func didSucceedReconnection() {
    let manager: SBSMSyncManager = SBSMSyncManager()
    manager.resumeSynchronize()
}
```
```objc
// objective-c

// Request Connect to SendBird
[SBDMain connectWithUserId:userId completionHandler:^(SBDUser * _Nullable user, SBDError * _Nullable error) {
    if (error != nil) {
        // 
        return;
    }
    
    SBSMSyncManager *manager = [SBSMSyncManager manager];
    [manager resumeSynchronize];
}];

// SendBird Connection Delegate
- (void)didSucceedReconnection {
    SBSMSyncManager *manager = [SBSMSyncManager manager];
    [manager resumeSynchronize];
}
```

### Cache clear

Clearing cache is necessary when a user signs out (called `disconnect()` explicitly).

```swift
// swift
SBDMain.disconnect {
    let manager: SBSMSyncManager = SBSMSyncManager()
    manager.clearCache()
}
```
```objc
// objective-c
[SBDMain disconnectWithCompletionHandler:^{
    [[SBSMSyncManager manager] clearCache];
}];
```

> WARNING! DO NOT call `SBDMain.removeAllChannelDelegates()`. It does not only remove handlers you added, but also remove handlers managed by SyncManager.

