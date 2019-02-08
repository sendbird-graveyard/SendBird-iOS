# SendBird-iOS-LocalCache-Sample
The repository for a sample project that use `SendBird SDK Manager` for **LocalCache**. Manager offers an event-based data management so that each view would see a single spot by subscribing data event. And it stores the data into database which implements local caching for faster loading.  

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

## Install SendBird Framework from Carthage

1. Add `github "smilefam/sendbird-syncmanager-ios"` to your `Cartfile`.
2. Run `carthage update`.
3. Go to your Xcode project's "General" settings. Open `<YOUR_XCODE_PROJECT_DIRECTORY>/Carthage/Build/iOS` in Finder and drag `SendBirdSyncManager.framework` to the "Embedded Binaries" section in Xcode. Make sure `Copy items if needed` is selected and click `Finish`.

## Usage

### Initialization
```objc
// AppDelegate.m
- (BOOL)application:(UIApplication *)application 
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ...

    [SBSMChannelManager sharedInstance];

    ...
}
```

### Channel Manager

```objc
// GroupChannelListViewController.h

#import <SendBirdSDK/SendBirdSDK.h>
#import "SyncManager.h"

@interface GroupChannelListViewController : UIViewController <SBSMCollectionDelegate>
@end

// GroupChannelListViewController.m

@implementation GroupChannelListViewController

- (void)collection:(id<SBSMCollection> _Nonnull)collection
      updatedItmes:(nonnull NSArray <id<SBSMObject>> *)updatedItems
            action:(SBSMChangeLogAction)action
             error:(nullable NSError *)error {
    switch(action) {
        case SBSMChangeLogActionPrepend:
        // Update UI
            break;
        case SBSMChangeLogActionAppend:
        // Update UI
            break;
        case SBSMChangeLogActionNew:
        // Update UI
            break;
        case SBSMChangeLogActionChanged:
        // Update UI
            break;
        case SBSMChangeLogActionDeleted:
        // Update UI
            break;
        case SBSMChangeLogActionMoved:
        // Update UI
            break;
        case SBSMChangeLogActionCleared:
        // Update UI
            break;
    }
}

// ...
// to load channels
SBDGroupChannelListQuery *query = [SBDGroupChannel createMyGroupChannelListQuery];
// ...setup your query here

SBSMChannelCollection *collection = [SBSMChannelManager createChannelCollectionWithQuery:query];
[collection loadWithFinishHandler:^(BOOL finished) {
  // This callback is useful only to check the end of loading.
  // The fetched channels would be translated into change logs and delivered to subscription.
}];
```

### Message Manager

```objc
// GroupChannelChattingViewController.h
#import <SendBirdSDK/SendBirdSDK.h>
#import "SyncManager.h"

@interface GroupChannelChattingViewController : UIViewController <SBSMCollectionDelegate>
@end
 
// GroupChannelChattingViewController.m
@implementation GroupChannelChattingViewController

- (void)collection:(id<SBSMCollection> _Nonnull)collection
      updatedItmes:(nonnull NSArray <id<SBSMObject>> *)updatedItems
            action:(SBSMChangeLogAction)action
             error:(nullable NSError *)error {
    switch(action) {
        case SBSMChangeLogActionPrepend:
            break;
        case SBSMChangeLogActionAppend:
            break;
        case SBSMChangeLogActionNew:
            break;
        case SBSMChangeLogActionChanged:
            break;
        case SBSMChangeLogActionDeleted:
            break;
        case SBSMChangeLogActionMoved:
            break;
        case SBSMChangeLogActionCleared:
            break;
    }
}

// ...
// to load messages
SBDGroupChannel *channel; // channel of messages
NSDictionary filter = @{}; // compose your own filter

SBSMMessageCollection* collection = [SBSMMessageManager createMessageCollectionWithChannel:channel 
                                                                                    filter:filter];
[collection loadPreviousMessagesWithFinishHandler:^(BOOL finished) {
    // This callback is useful only to check the end of loading.
    // The fetched messages would be translated into change logs and delivered to subscription.
}];
```

SyncManager listens message event handlers such as `didReceiveMessage`, `didUpdateMessage`, `didDeleteMessage`, and applies the change automatically. But they would not be called if the message is sent by `currentUser`. You can keep track of the message in callback instead. SyncManager provides some methods to apply the message event to collections.

```objc
// call [SBSMMessageManager appendMessage] after sending message
SBUserMessageParams *params = [[SBUserMessageParams alloc] init];
params.message = @"your message";
[channel sendUserMessage:param 
       completionHandler:^(SBDBaseMessage * _Nullable message, SBDError * _Nullable error) {
    if(error == nil) {
        [SBSMMessageManager appendMessage:message];
    }
}];

// call [SBSMMessageManager updateMessage] after updating message
SBUserMessageParams *params = [[SBUserMessageParams alloc] init];
params.message = @"your message";
[channel updateUserMessage:message.messageId,
                    params:params
         completionHandler:^(SBDBaseMessage * _Nullable message, SBDError * _Nullable error) {
    if(error == nil) {
        [SBSMMessageManager updateMessage:message];
    }
}];

// call [SBSMMessageManager deleteMessage] after deleting message
[channel deleteMessage:message
     completionHandler:^(SBDBaseMessage * _Nullable message, SBDError * _Nullable error) {
    if(error == nil) {
        [SBSMMessageManager deleteMessage:message];
    }
}];
```

Once it is delivered to the collection, it'd not only apply the change into the current collection but also propagate the event into other collections so that the change could apply to other views automatically. It works only for messages sent by `currentUser`(from `[SBDMain getCurrentUser]`) which means the message sender should be `currentUser`.

### Connection Lifecycle

Connection may not be stable in some environment. If SendBird recognizes disconnection, it would take steps for reconnection and manager would catch it and sync data automatically when the connection is back. For those who call `[SBDMain disconnectWithCompletionHandler:]` and `[SBDMain connectWithUserId:accessToken:completionHandler:]` explicitly to manage the lifecycle by their own, Manager provides methods `[SBSMChannelManager start]`, `[SBSMMessageManager start]` and `[SBSMChannelManager stop]`, `[SBSMMessageManager stop]` to acknowledge the event and do proper action in order to sync content.
