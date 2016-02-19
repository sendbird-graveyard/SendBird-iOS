# [SendBird](https://sendbird.com) - Messaging and Chat API for Mobile Apps and Websites
[SendBird](https://sendbird.com) provides the chat API and SDK for your app enabling real-time communication among your users.

## Documentation
https://sendbird.gitbooks.io/sendbird-ios-sdk/content/en/

## Install SendBird Framework from CocoaPods

Add below into your Podfile on Xcode.

For a ***Swift*** project, you should use ```use_frameworks!``` in Podfile.

```
# Uncomment this line if you're using Swift
# use_frameworks!

pod 'SendBirdSDK'
```

Install SendBird Framework through CocoaPods.

```
pod install
```

Now you can see installed SendBird framework by inspecting YOUR_PROJECT.xcworkspace.

## Quick Guide

### Initialization

#### Objective-C

AppDelegate.m


```objectivec
#import <SendBirdSDK/SendBirdSDK.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // ..

    NSString *APP_ID = @“<YOUR_APP_ID>”;
    [SendBird initAppId:APP_ID];

    // ..

    return YES;
}
```

#### Swift

AppDelegate.swift

```swift
import SendBirdSDK

class AppDelegate: UIResponder, UIApplicationDelegate {
    // ..

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // ..
        let APP_ID: String = “<YOUR_APP_ID>”
        SendBird.initAppId(APP_ID)
        // ..

        return true
    }

    // ..
}
```

### Register SendBird Event Handler

#### Objective-C

YourViewController.m

```objectivec
[SendBird setEventHandlerConnectBlock:^(SendBirdChannel *channel) {
  // ..
} errorBlock:^(NSInteger code) {
  // ..
} channelLeftBlock:^(SendBirdChannel *channel) {
  // ..
} messageReceivedBlock:^(SendBirdMessage *message) {
  // ..
} systemMessageReceivedBlock:^(SendBirdSystemMessage *message) {
  // ..
} broadcastMessageReceivedBlock:^(SendBirdBroadcastMessage *message) {
  // ..
} fileReceivedBlock:^(SendBirdFileLink *fileLink) {
  // ..
} messagingStartedBlock:^(SendBirdMessagingChannel *channel) {
  // ..
} messagingUpdatedBlock:^(SendBirdMessagingChannel *channel) {
  // ..
} messagingEndedBlock:^(SendBirdMessagingChannel *channel) {
  // ..
} allMessagingEndedBlock:^ {
  // ..
} messagingHiddenBlock:^(SendBirdMessagingChannel *channel) {
  // ..
} allMessagingHiddenBlock:^ {
  // ..        
} readReceivedBlock:^(SendBirdReadStatus *status) {
  // ..        
} typeStartReceivedBlock:^(SendBirdTypeStatus *status) {
  // ..        
} typeEndReceivedBlock:^(SendBirdTypeStatus *status) {
  // ..        
} allDataReceivedBlock:^(NSUInteger sendBirdDataType, int count) {
  // ..
} messageDeliveryBlock:^(BOOL send, NSString *message, NSString *data, NSString *messageId) {
  // ..
}];
```

#### Swift

YourViewController.swift

```swift
SendBird.setEventHandlerConnectBlock({ (channel) -> Void in
  // ..
}, errorBlock: { (code) -> Void in
  // ..
}, channelLeftBlock: { (channel) -> Void in
  // ..
}, messageReceivedBlock: { (message) -> Void in
  // ..
}, systemMessageReceivedBlock: { (message) -> Void in
  // ..
}, broadcastMessageReceivedBlock: { (message) -> Void in
  // ..
}, fileReceivedBlock: { (fileLink) -> Void in
  // ..
}, messagingStartedBlock: { (channel) -> Void in
  // ..
}, messagingUpdatedBlock: { (channel) -> Void in
  // ..
}, messagingEndedBlock: { (channel) -> Void in
  //  ..
}, allMessagingEndedBlock: { () -> Void in
  // ..
}, messagingHiddenBlock: { (channel) -> Void in
  // ..
}, allMessagingHiddenBlock: { () -> Void in
  // ..
}, readReceivedBlock: { (status) -> Void in
  // ..
}, typeStartReceivedBlock: { (status) -> Void in
  // ..
}, typeEndReceivedBlock: { (status) -> Void in
  // ..
}, allDataReceivedBlock: { (sendBirdDataType, count) -> Void in
  // ..
}) { (send, message, data, messageId) -> Void in
  // ..
}
```

### Login

#### Objective-C

YourViewController.m

```objectivec
[SendBird loginWithUserId:USER_ID andUserName:USER_NAME];
```


#### Swift

YourViewController.swift

```swift
SendBird.loginWithUserId(USER_ID, andUserName: USER_NAME)
```

### Join Channel

#### Objective-C

YourViewController.m

```objectivec
[SendBird joinChannel:CHANNEL_URL];
[SendBird connect];
```

#### Swift

YourViewController.swift

```swift
SendBird.joinChannel(CHANNEL_URL)
SendBird.connect()
```

### Send Message

#### Objective-C

YourViewController.m

```objectivec
[SendBird sendMessage:message];
```

#### Swift

YourViewController.swift

```swift
SendBird.sendMessage(message)
```


## Sample
You can download [a sample app](https://github.com/smilefam/SendBird-iOS)

## Other platforms
* [Android](https://sendbird.gitbooks.io/sendbird-android-sdk/content/en/index.html)
* [Unity SDK](https://sendbird.gitbooks.io/sendbird-unity-sdk/content/en/index.html)
* [Web(JavaScript)](https://sendbird.gitbooks.io/sendbird-web-sdk/content/en/index.html)
* [Server API](https://sendbird.gitbooks.io/sendbird-server-api/content/en/index.html)
* [Xamarin](https://sendbird.gitbooks.io/sendbird-xamarin-sdk/content/)
