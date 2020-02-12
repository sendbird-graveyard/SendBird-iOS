//
//  AppDelegate.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/3/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import UserNotifications
import SendBirdSDK
import AVKit
import AVFoundation
import SwiftyBeaver

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, SBDChannelDelegate {

    var window: UIWindow?
    var receivedPushChannelUrl: String?
    var pushReceivedGroupChannel: String?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
           
        // Connect Logger
        // TODO: Remove Logger
        Logger.addDestination(ConsoleDestination())
         
        // Connect SendBird
        SBDMain.setLogLevel(SBDLogLevel.none)
        SBDMain.initWithApplicationId("9DA1B1F4-0BE6-4DA8-82C5-2E81DAB56F23")
        SBDMain.add(self as SBDChannelDelegate, identifier: self.description)
        self.registerForRemoteNotification()
        
        UINavigationBar.appearance().tintColor = UIColor(named: "color_navigation_tint")
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        
        if #available(iOS 13.0, *) {
            // Refers to SceneDelegate.swift
        }
        else {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            if let window = self.window {
                let loginVC = LoginViewController.initiate()
                window.rootViewController = loginVC
                window.makeKeyAndVisible()
            }
        }

        return true
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        connectingSceneSession.userInfo?["activity"] = options.userActivities.first?.activityType
        
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    // MARK: - Notification for Foreground mode
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func registerForRemoteNotification() {
        
#if targetEnvironment(simulator)
        
        guard Double(UIDevice.current.systemVersion)! >= 10.0 else { return }
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert]) { _, _ in }
        
#else
        
        guard let systemVersion = Double(UIDevice.current.systemVersion), systemVersion >= 10.0 else {
            guard UIApplication.shared.responds(to: #selector(UIApplication.registerUserNotificationSettings(_:))) else { return }
            let notificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(notificationSettings)
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
            return
        }
        
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            guard granted else { return }
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                guard settings.authorizationStatus == .authorized else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        
#endif
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        SBDMain.registerDevicePushToken(deviceToken, unique: true) { status, error in
            
            switch status {
            case .success:
                print("APNS Token is registered.")
            case .pending:
                print("Push registration is pending.")
            case .error:
                print("APNS registration failed with error: \(String(describing: error ?? nil))")
                
            @unknown default:
                print("Push registration: unknown default")
                assertionFailure()
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to get token, error: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        guard let sendbirdDict = userInfo["sendbird"] as? [String: Any],
            let channelDict = sendbirdDict["channel"] as? [String: Any]
            else { return }
        
        self.pushReceivedGroupChannel = channelDict["channel_url"] as? String
    }
    // MARK: - SBDChannelDelegate
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        guard let groupChannel = sender as? SBDGroupChannel, groupChannel.myPushTriggerOption == .off else { return }
        
        let topViewController = UIViewController.currentViewController()
        if topViewController is GroupChannelsViewController {
            return
        }
        
        if let vc = topViewController as? GroupChannelChatViewController {
            if vc.channel?.channelUrl == sender.channelUrl {
                return
            }
        }
        
        // Do Not Disturb - Need to implement as a function
        let startHour: Int = UserDefaults.standard.value(forKey: "sendbird_dnd_start_hour") as? Int ?? -1
        let startMin: Int = UserDefaults.standard.value(forKey: "sendbird_dnd_start_min") as? Int ?? -1
        let endHour: Int = UserDefaults.standard.value(forKey: "sendbird_dnd_end_hour") as? Int ?? -1
        let endMin: Int = UserDefaults.standard.value(forKey: "sendbird_dnd_end_min") as? Int ?? -1
        let isDoNotDisturbOn: Bool = UserDefaults.standard.value(forKey: "sendbird_dnd_on") as? Bool ?? false
        
        if startHour != -1 && startMin != -1 && endHour != -1 && endMin != -1 && isDoNotDisturbOn {
            let date = Date()
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: date)
            let hour = components.hour
            let minute = components.minute
            
            let convertedStartMin = startHour * 60 + startMin
            let convertedEndMin = endHour * 60 + endMin
            let convertedCurrentMin = hour! * 60 + minute!
            
            if convertedStartMin <= convertedEndMin, convertedStartMin <= convertedCurrentMin, convertedEndMin >= convertedCurrentMin {
                return
            } else if convertedStartMin > convertedEndMin, (convertedStartMin < convertedCurrentMin || convertedEndMin > convertedCurrentMin) {
                return
            }
        }
        
        var title = ""
        var body = ""
        var type = ""
        var customType = ""
        if message is SBDUserMessage {
            let userMessage = message as! SBDUserMessage
            let sender = userMessage.sender
            type = "MESG"
            body = String(format: "%@: %@", (sender?.nickname)!, userMessage.message!)
            customType = userMessage.customType!
        } else if message is SBDFileMessage {
            let fileMessage = message as! SBDFileMessage
            let sender = fileMessage.sender
            
            if fileMessage.type.hasPrefix("image") {
                body = String(format: "%@: (Image)", (sender?.nickname)!)
            } else if fileMessage.type.hasPrefix("video") {
                body = String(format: "%@: (Video)", (sender?.nickname)!)
            } else if fileMessage.type.hasPrefix("audio") {
                body = String(format: "%@: (Audio)", (sender?.nickname)!)
            } else {
                body = String(format: "%@: (File)", sender!.nickname!)
            }
        } else if message is SBDAdminMessage {
            let adminMessage = message as! SBDAdminMessage
            
            title = ""
            body = adminMessage.message!
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "SENDBIRD_NEW_MESSAGE"
        content.userInfo = [
            "sendbird": [
                "type": type,
                "custom_type": customType,
                "channel": [
                    "channel_url": sender.channelUrl
                ],
                "data": "",
            ],
        ]
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: String(format: "%@_%@", content.categoryIdentifier, sender.channelUrl), content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            if error != nil {
                
            }
        }
    }
    
    func channel(_ sender: SBDGroupChannel, userDidLeave user: SBDUser) {

    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard
            let userInfo = response.notification.request.content.userInfo as? [String: Any],
            let sendbirdDict = userInfo["sendbird"] as? [String: Any],
            let channelDict = sendbirdDict["channel"] as? [String: Any],
            let channelUrl = channelDict["channel_url"] as? String
            else { return }
        
        self.pushReceivedGroupChannel = channelUrl
        
        ConnectionControl
            .setLoginInfoByLastSuccess()
            .login(
                success: { user in
                    
                    guard let channelURL = self.pushReceivedGroupChannel else {
                        let initialVC = UIStoryboard(name: "main", bundle: nil).instantiateInitialViewController()
                        self.window = UIWindow(frame: UIScreen.main.bounds)
                        self.window?.rootViewController = initialVC
                        self.window?.makeKeyAndVisible()
                        return
                    }
                    if let currentVC = UIViewController.currentViewController() {
                        currentVC.dismiss(animated: false) {
                            self.jumpToGroupChannel(channelURL)
                        }
                    } else {
                        let tabBarVC = MainTabBarController.initiate() 
                        
                        self.window = UIWindow(frame: UIScreen.main.bounds)
                        self.window?.rootViewController = tabBarVC
                        self.window?.makeKeyAndVisible()
                        
                        self.jumpToGroupChannel(channelURL)
                    }
                    
                    self.pushReceivedGroupChannel = nil
                    completionHandler()
            }, failure: { _ in
                completionHandler()
                
            }
        )
    }
    
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func jumpToGroupChannel(_ channelURL: String) -> Void {
        let delegate = UIViewController.currentViewController() as? NotificationDelegate
        delegate?.openChat(channelURL)
    }
    
}

