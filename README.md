# [SendBird](https://sendbird.com) iOS Sample UI
![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)
![Languages](https://img.shields.io/badge/language-Objective--C%20%7C%20Swift-orange.svg)

## Introduction

[SendBird](https://sendbird.com) provides the chat API and SDK for your app enabling real-time communication
among your users. 

## Quick Start

1. Download Sample UI project from this repository.
2. Open the project.
3. Build and run it.

## Swift 2.3 support

* Swift 2.3 -> `swift-2.3-sample` directory in `v3-old` branch

## Access to Version 2

You can check out `v2` branch instead of `master` branch to download version 2 samples.

## SyncManager
`SyncManager` is a support add-on for [SendBird SDK](https://github.com/smilefam/sendbird-ios-framework). Major benefits of `SyncManager` are,  
  
 * Local cache integrated: store channel/message data in local storage for fast view loading.  
 * Event-driven data handling: subscribe channel/message event like `insert`, `update`, `remove` at a single spot in order to apply data event to view.  
  
Check out [iOS Sample with SyncManager](https://github.com/smilefam/SendBird-iOS-LocalCache-Sample) which is same as [iOS Sample](https://github.com/smilefam/SendBird-iOS) with `SyncManager` integrated.    
For more information about `SyncManager`, please refer to [SyncManager README](https://github.com/smilefam/SendBird-iOS-LocalCache-Sample/blob/master/README.md). 