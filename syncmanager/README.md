# SendBird SyncManager Sample 
The repository for a sample project that use `SendBird SyncManager` for **LocalCache**. Manager offers an event-based data management so that each view would see a single spot by subscribing data event. And it stores the data into database which implements local caching for faster loading.  

## SendBird SyncManager Framework
Refers to [SendBird SyncManager Framework](https://github.com/smilefam/sendbird-syncmanager-ios)

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

> Note: `SendBirdSyncManager` is dependent with `SendBird SDK`. If you install `SendBirdSyncManager`, Cocoapods automatically install `SendBird SDK` as well. And the minimum version of `SendBird SDK` is **3.0.130**.

## Install SendBird Framework from Carthage

1. Add `github "smilefam/sendbird-syncmanager-ios"` to your `Cartfile`.
2. Run `carthage update`.
3. Go to your Xcode project's "General" settings. Open `<YOUR_XCODE_PROJECT_DIRECTORY>/Carthage/Build/iOS` in Finder and drag `SendBirdSyncManager.framework` to the "Embedded Binaries" section in Xcode. Make sure `Copy items if needed` is selected and click `Finish`.

> Note: `SendBirdSyncManager` is dependent with `SendBird SDK`. So if you install from Carthage, you should instal [SendBird SDK][https://github.com/smilefam/sendbird-ios-framework]. Keep in mind the version of `SendBird SDK` should be higher than **3.0.130**.

## Usage

### Initialization
`SBSMSyncManager` is singlton class. And when `SBSMSyncManager` was initialized, a instance for `Database` is set up. So if you want to initialize `Database` as soon as possible, call `setup(_:)` first just after you get a user's ID. we recommend it is in `application(_:didFinishLaunchingWithOptions:)`.
```swift
// swift
// AppDelegate.swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    // after getting user's ID or login
    SBSMSyncManager.setup(withUserId: userId)
}
```
```objc
// objective-c
// AppDelegate.m
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // after getting user's ID or login
    [SBSMSyncManager setupWithUserId:userId];
}];
```

### Collection

`Collection` is a container to manage SendBird objects(`SBDGroupChannel`, `SBDBaseMessage`) related to a view. `SBSMChannelCollection` is attached to channel list view contoller and `SBSMMessageCollection` is attached to message list view contoller accordingly. The main purpose of `Collection` is,

- To listen data event and deliver it as view event.
- To fetch data from cache or SendBird server and deliver the data as view event.

To meet the purpose, each collection has event subscriber and data fetcher. Event subscriber listens data event so that it could apply data update into view, and data fetcher loads data from cache or server and sends the data to event handler.

#### Channel Collection
Channel is quite mutable data where chat is actively going - channel's last message and unread message count may update very often. Even the position of each channel is changing drastically since many apps sort channels by the most recent message. For that reason, `SBSMChannelCollection` depends mostly on server sync. Here's the process `SBSMChannelCollection` synchronizes data:

1. It loads channels from cache and the view shows them.
2. Then it fetches the most recent channels from SendBird server and merges with the channels in view.
3. It fetches from SendBird server every time `fetch(_:)` is called in order to view previous channels.

> Note: Channel data sync mechanism could change later.

`SBSMChannelCollection` requires `SBDGroupChannelListQuery` instance of [SendBirdSDK](https://github.com/smilefam/sendbird-ios-framework) as it binds the query into the collection. Then the collection filters data with the query. Here's the code to create new `SBSMChannelCollection` instance. The creation of channel collection is usually in `viewDidLoad()` of group channel list view controller.

```swift
// swift
override func viewDidLoad() {
    let query: SBDGroupChannelListQuery? = SBDGroupChannel.createMyGroupChannelListQuery()
    // limit, order, ... setup your query here. 
    let channelCollection: SBSMChannelCollection? = SBSMChannelCollection.init(query: query)
    self.channelCollection? = channelCollection // Recommands to set a property of view controller
}
```
```objc
// objective-c
- (void)viewDidLoad {    
    SBDGroupChannelListQuery *query = [SBDGroupChannel createMyGroupChannelListQuery];
    // limit, order, ... setup your query here. 
    SBSMChannelCollection *channelCollection = [SBSMChannelCollection collectionWithQuery:query];
    self.channelColletion = channelCollection; // Recommands to set a property of view controller
}
```

If the view is closed, which means the collection is obsolete and no longer used, remove collection explicitly. In viewcontroller, it will be in `deinit`(`dealloc`).

```swift
// swift
deinit {
    channelCollection?.delegate = nil
    channelCollection?.remove()
}
```
```objc
// objective-c
- (void)dealloc {
    if (channelCollection != nil) {
        channelCollection.delegate = nil;
    }
    
    [channelCollection remove];
}
```

As aforementioned, `SBSMChannelCollection` provides event handler with delegate. Event handler is named as `SBSMChannelCollectionDelegate` and it receives `SBSMChannelEventAction` and list of `channels` when an event has come. The `SBSMChannelEventAction` is a keyword to notify what happened to the channel list, and the `channel` is a kind of `SBDGroupChannel` instance. You can create an view controller instance and implement the event handler and add it to the collection.

```swift
// swift

// add delegate
import SendBirdSyncManager

class GroupChannelListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SBSMChannelCollectionDelegate {
    override func viewDidLoad() {
        // ...
        channelCollection?.delegate = self
        // ...
    }

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
}
```
```objc
// objective-c

// add delegate
#import <SendBirdSyncManager/SendBirdSyncManager.h>
@interface GroupChannelListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SBSMChannelCollectionDelegate>
@end

@implementation GroupChannelListViewController
- (void)viewDidLoad {    
    channelCollection.delegate = self;
    // ..
}

// channel collection delegate
- (void)collection:(SBSMChannelCollection *)collection didReceiveEvent:(SBSMChannelEventAction)action channels:(NSArray<SBDGroupChannel *> *)channels {
    guard collection == self.channelCollection, channels.count > 0 else {
        return
    }

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

And data fetcher. Fetched channels would be delivered to delegate method. fetcher determines the `SBSMChannelEventAction` automatically so you don't have to consider duplicated data in view. Generally `fetch(_:)` is called when view was created, user requests next page of channel list and user wants to refresh channel list.

```swift
// swift
override viewDidLoad() {
    channelCollection.fetch(completionHandler: {(error) in
        // This callback is optional and useful to catch the moment of loading ended.
    })
}

func refreshChannel() {
    // begin loading progress
    channelCollection?.remove()
    channelCollection? = nil
    // create channel collection
    channelCollection?.fetch(completionHandler: { (error) in
        // end load progress
    })
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // .. dequeue reusable cell        
    if self.channels.count > 0 && indexPath.row + 1 == self.channels.count {
        channelCollection?.fetch(completionHandler: { (error) in
            // end load progress
        })
    }
    // ...
}
```
```objc
// objective-c
- (void)viewDidLoad {    
    [channelCollection fetchWithCompletionHandler:^(SBDError * _Nullable error) {
        // This callback is optional and useful to catch the moment of loading ended.
    }];
}

- (void)refreshChannel {
    // begin loading progress
    [channelCollection remove];
    channelCollection = nil;
    // create channel collection 
    [channelCollection fetchWithCompletionHandler:^(SBDError * _Nullable error) {
        // end loading progress
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // .. dequeue reusable cell

    if (self.channels.count > 0 && indexPath.row + 1 == self.channels.count) {
        // start loading progress
        [self.channelCollection fetchWithCompletionHandler:^(SBDError * _Nullable error) {
            // end loading progress
        }];
    }

    // ...
}    

```

#### Message Collection
Message is relatively static data and SyncManager supports full-caching for messages. `SBSMMessageCollection` conducts background synchronization so that it synchronizes all the messages until it reaches to the first message. Background synchronization does NOT affect view directly but store for local cache. For view update, explicitly call `fetch(_:_:)` with direction which fetches data from cache and sends the data into collection handler. 

Background synchronization ceases if the synchronization is done or synchronization request is failed.

> Note: Background synchronization run in background thread.

For various viewpoint(`viewpointTimestamp`) support, `SBSMMessageCollection` sets a timestamp when to fetch messages. The `viewpointTimestamp` is a timestamp to start background synchronization in both previous and next direction (and also the point where a user sees at first). Here's the code to create `SBSMMessageCollection`.

The creation of message collection is usually in `viewDidLoad()` of message list view controller as well as channel collection.

```swift
// swift
override viewDidLoad() {
    // ...
    let filter: SBSMMessageFilter = SBSMMessageFilter.init(messageType: SBDMessageTypeFilter, customType: customTypeFilter, senderUserIds: senderUserIdsFilter)
    let viewpointTimestamp: Int64 = getLastReadTimestamp()
    // or LONG_LONG_MAX if you want to see the most recent messages

    let messageCollection: SBSMMessageCollection? = SBSMMessageCollection.init(channel: channel, filter: filter, viewpointTimestamp: viewpointTimestamp)
    // ...
}
```
```objc
// objective-c
- (void)viewDidLoad {
    // ...
    SBSMMessageFilter *filter = [SBSMMessageFilter filterWithMessageType:SBDMessageTypeFilter customType:customtypeFilter senderUserIds:senderUserIdsFilter];
    long long viewpointTimestamp = getLastReadTimestamp();
    // or LONG_LONG_MAX if you want to see the most recent messages

    SBSMMessageCollection *messageCollection = [SBSMMessageCollection collectionWithChannel:self.channel filter:filter viewpointTimestamp:viewpointTimestamp];
    // ...
}
```

You can dismiss collection when the collection is obsolete and no longer used. It is recommanded for `remove()` to be in `deinit` of message view contorller.

```swift
// swift
deinit {
    messageCollection?.delegate = nil
    messageCollection?.remove()
}
```
```objc
- (void)dealloc {
    if (self.messageCollection != nil) {
        self.messageCollection.delegate = nil;
    }

    [messageCollection remove];
}
```

`SBSMMessageCollection` has event handler for delegate that you can implement and add to the collection. Event handler is named as `SBSMMessageCollectionDelegate` and it receives `SBSMMessageEventAction` and list of `messages` when an event has come. The `SBSMMessageEventAction` is a keyword to notify what happened to the message, and the `message` is a kind of `SBDBaseMessage` instance of [SendBird SDK](https://github.com/smilefam/sendbird-ios-framework).

```swift
// swift

// add delegate
import SendBirdSyncManager
class GroupChannelChattingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SBSMMessageCollectionDelegate {
    override func viewDidLoad() {
        // ...
        messageCollection.delegate = self
        // ...
    }

    // message collection delegate
    func collection(_ collection: SBSMMessageCollection, didReceiveEvent action: SBSMMessageEventAction, messages: [SBDBaseMessage]) {
        guard collection == self.messageCollection, messages.count > 0 else {
            return
        }

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
}
```
```objc
// objective-c

// add delegate
#import <SendBirdSyncManager/SendBirdSyncManager.h>
@interface GroupChannelChattingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SBSMMessageCollectionDelegate, SBDConnectionDelegate>
@end

@implementation GroupChannelChattingViewController
- (void)viewDidLoad {
    // ..
    messageCollection.delegate = self;
    // ..
}

// message collection delegate
- (void)collection:(SBSMMessageCollection *)collection didReceiveEvent:(SBSMMessageEventAction)action messages:(NSArray<SBDBaseMessage *> *)messages {
    if (self.messageCollection != collection || messages.count == 0) {
        return;
    }

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

`SBSMMessageCollection` has data fetcher by direction: `SBSMMessageDirection.previous` and `SBSMMessageDirection.next`. It fetches data from cache only and never request to server directly. If no more data is available in a certain direction, it wait for the background synchronization internally and fetches the synced messages right after the synchronization progresses. Generally call `fetch(_:_:)` when view was created, user requests previous/next page of message list and user wants to refresh message list, and received an event of reconnection success.

>> NOTE: You can get as many messages as your calling of `fetch(_:_:)` method if your device stores enough messages. So you should make sure that you do not call `fetch(_:_:)` more than you intended. We control it with `loading` flag in sample project.

```swift
// swift
override func viewDidLoad() {
    messageCollection.fetch(in: SBSMMessageDirection.previous, completionHandler: { (error) in
        // Fetching from cache is done
    })
    messageCollection.fetch(in: SBSMMessageDirection.next, completionHandler: { (error) in
        // Fetching from cache is done
    })
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // .. dequeue reusable cell        
    if self.channels.count > 0 && indexPath.row + 1 == self.channels.count {
        messageCollection?.fetch(in: direction, completionHandler: { (error) in
            // Fetching from cache is done
        })
    }
    // ...
}

func refreshMessages() {
    messageCollection?.resetViewpointTimestamp(getLastReadTimestamp())
    messageCollection?.fetch(in: direction, completionHandler: { (error) in
        // Fetching from cache is done
    })
}

// MARK SendBird Connection Delegate
func didSucceedReconnection() {
    messageCollection?.resetViewpointTimestamp(getLastReadTimestamp())
    messageCollection?.fetch(in: direction, completionHandler: { (error) in
        // Fetching from cache is done
    })
}
```
```objc
// objective-c
- (void)viewDidLoad {
    // ..
    [messageCollection fetchInDirection:SBSMMessageDirectionPrevious completionHandler:^(SBDError * _Nullable error) {
        // Fetching from cache is done
    }];
    [messageCollection fetchInDirection:SBSMMessageDirectionNext completionHandler:^(SBDError * _Nullable error) {
        // Fetching from cache is done
    }];
    // ..
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // .. dequeue reusable cell

    if (self.messages.count > 0 && indexPath.row + 1 == self.messages.count) {
        [messageCollection fetchInDirection:direction completionHandler:^(SBDError * _Nullable error) {
            // fetching from cache is done
        }];
    }

    // ...
}

- (void)refreshMessages {
    [messageCollection resetViewpointTimestamp:getLastReadTimestamp()];
    [messageCollection fetchInDirection:direction completionHandler:^(SBDError * _Nullable error) {
        // Fetching from cache is done
    }];
}

#pragma mark - SendBird Connection Delegate
- (void)didSucceedReconnection {
    [messageCollection resetViewpointTimestamp:getLastReadTimestamp()];
    [messageCollection fetchInDirection:direction completionHandler:^(SBDError * _Nullable error) {
        // Fetching from cache is done
    }];
}

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

You should choose an action after execute `disconnect()` explicitly. You can clear the current user's database or stop synchronizing.

```swift
// swift
SBDMain.disconnect {

    // clear cache
    SBSMSyncManager().clearCache()

    // stop synchronizing
    SBSMSyncManager().pauseSynchronize()
}
```
```objc
// objective-c
[SBDMain disconnectWithCompletionHandler:^{

    // clear cache
    [[SBSMSyncManager manager] clearCache];

    // stop synchronizing
    [[SBSMSyncManager manager] pauseSynchronize];
}];
```

> WARNING! DO NOT call `SBDMain.removeAllChannelDelegates()`. It does not only remove handlers you added, but also remove handlers managed by SyncManager.

