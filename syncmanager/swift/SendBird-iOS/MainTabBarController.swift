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

class MainTabBarController: UITabBarController, SBDConnectionDelegate, SBDNetworkDelegate {
    private static let TITLE_GROUP_CHANNELS = "Group"
    private static let TITLE_SETTINGS = "Settings"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.tintColor = UIColor(named: "color_bar_item")
    }

    // MARK: SBDNetworkDelegate
    @objc func didReconnect() {
        
    }
}

extension MainTabBarController {
    static func initiate() -> MainTabBarController {
        let vc = MainTabBarController.withStoryboard(storyboard: .main)
        return vc
    }
}
