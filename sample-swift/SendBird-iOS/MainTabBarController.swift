//
//  MainTabBarController.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/12/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import UserNotifications

class MainTabBarController: UITabBarController, SBDConnectionDelegate, SBDChannelDelegate, SBDNetworkDelegate {
    private static let TITLE_GROUP_CHANNELS = "Group Channels"
    private static let TITLE_OPEN_CHANNELS = "Open Channels"
    private static let TITLE_SETTINGS = "Settings"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        SBDConnectionManager.add(self as SBDNetworkDelegate, identifier: self.description)
        SBDMain.add(self as SBDChannelDelegate, identifier: self.description)
        
        let groupChannelsNavigationController = GroupChannelsNavigationController()
        let groupChannelsTabBarItem = UITabBarItem.init(title: MainTabBarController.TITLE_GROUP_CHANNELS, image: UIImage(named: "img_tab_group_channel_normal"), selectedImage: UIImage(named: "img_tab_group_channel_selected"))
        groupChannelsNavigationController.tabBarItem = groupChannelsTabBarItem
        
        let openChannelsNavigationController = OpenChannelsNavigationController()
        let openChannelsTabBarItem = UITabBarItem.init(title: MainTabBarController.TITLE_OPEN_CHANNELS, image: UIImage(named: "img_tab_open_channel_normal"), selectedImage: UIImage(named: "img_tab_open_channel_selected"))
        openChannelsNavigationController.tabBarItem = openChannelsTabBarItem
        
        let settingsNavigationController = SettingsNavigationController()
        let settingsTabBarItem = UITabBarItem.init(title: MainTabBarController.TITLE_SETTINGS, image: UIImage(named: "img_tab_settings_normal"), selectedImage: UIImage(named: "img_tab_settings_selected"))
        settingsNavigationController.tabBarItem = settingsTabBarItem
        
        self.tabBar.tintColor = UIColor(named: "color_bar_item")
        
        self.addChild(groupChannelsNavigationController)
        self.addChild(openChannelsNavigationController)
        self.addChild(settingsNavigationController)
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.title == MainTabBarController.TITLE_GROUP_CHANNELS || item.title == MainTabBarController.TITLE_SETTINGS {
            for vc in self.children {
                if vc is OpenChannelsNavigationController {
                    let openChannelsNavigationController = vc as! OpenChannelsNavigationController
                    for openchatvc in openChannelsNavigationController.viewControllers {
                        if openchatvc is OpenChannelsViewController {
                            let openChannelsViewController = openchatvc as! OpenChannelsViewController
                            guard let searchController = openChannelsViewController.navigationItem.searchController else { continue }
                            if searchController.isActive {
                                searchController.isActive = false
                                searchController.dismiss(animated: true, completion: nil)
                                openChannelsViewController.clearSearchFilter()
                                openChannelsViewController.refreshChannelList()
                                break
                            }
                            break
                        }
                    }
                    break
                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: SBDNetworkDelegate
    @objc func didReconnect() {
        print()
    }
    
    // MARK: SBDChannelDelegate
    @objc func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        let topViewController = UIViewController.currentViewController()
        if topViewController is GroupChannelsViewController {
            return
        }
        
        if topViewController is GroupChannelChatViewController {
            let vc = topViewController as! GroupChannelChatViewController
            if vc.channel == nil || vc.channel!.channelUrl == sender.channelUrl {
                return
            }
        }
        
        if !(sender is SBDGroupChannel) {
            return
        }
        
        if !((sender as! SBDGroupChannel).isPushEnabled) {
            return
        }
        
        // Do not disturb.
        var startHour = 0
        var startMin = 0
        var endHour = 0
        var endMin = 0
        var isDoNotDisturbOn = false
        
        if UserDefaults.standard.value(forKey: "sendbird_dnd_start_hour") != nil {
            startHour = UserDefaults.standard.value(forKey: "sendbird_dnd_start_hour") as! Int
        }
        else {
            startHour = -1
        }
        
        if UserDefaults.standard.value(forKey: "sendbird_dnd_start_min") != nil {
            startMin = UserDefaults.standard.value(forKey: "sendbird_dnd_start_min") as! Int
        }
        else {
            startMin = -1
        }
        
        if UserDefaults.standard.value(forKey: "sendbird_dnd_end_hour") != nil {
            endHour = UserDefaults.standard.value(forKey: "sendbird_dnd_end_hour") as! Int
        }
        else {
            endHour = -1
        }
        
        if UserDefaults.standard.value(forKey: "sendbird_dnd_end_min") != nil {
            endMin = UserDefaults.standard.value(forKey: "sendbird_dnd_end_min") as! Int
        }
        else {
            endMin = -1
        }
        
        if UserDefaults.standard.value(forKey: "sendbird_dnd_on") != nil {
            isDoNotDisturbOn = UserDefaults.standard.value(forKey: "sendbird_dnd_on") as! Bool
        }
        
        if startHour != -1 && startMin != -1 && endHour != -1 && endMin != -1 && isDoNotDisturbOn {
            let date = Date()
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: date)
            let hour = components.hour
            let minute = components.minute
            
            let convertedStartMin = startHour * 60 + startMin
            let convertedEndMin = endHour * 60 + endMin
            let convertedCurrentMin = hour! * 60 + minute!
            
            if convertedStartMin <= convertedEndMin && convertedStartMin <= convertedCurrentMin && convertedEndMin >= convertedCurrentMin {
                return
            }
            else if convertedStartMin > convertedEndMin && (convertedStartMin < convertedCurrentMin || convertedEndMin > convertedCurrentMin) {
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
        }
        else if message is SBDFileMessage {
            let fileMessage = message as! SBDFileMessage
            let sender = fileMessage.sender
            
            if fileMessage.type.hasPrefix("image") {
                body = String(format: "%@: (Image)", (sender?.nickname)!)
            }
            else if fileMessage.type.hasPrefix("video") {
                body = String(format: "%@: (Video)", (sender?.nickname)!)
            }
            else if fileMessage.type.hasPrefix("audio") {
                body = String(format: "%@: (Audio)", (sender?.nickname)!)
            }
            else {
                body = String(format: "%@: (File)", sender!.nickname!)
            }
        }
        else if message is SBDAdminMessage {
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
}
