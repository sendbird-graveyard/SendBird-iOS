//
//  GroupChannelSettingsTableViewCellDelegate.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 11/16/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import Foundation
import SendBirdSDK

@objc protocol GroupChannelSettingsTableViewCellDelegate: NSObjectProtocol {
    @objc optional func willUpdateChannelNameAndCoverImage()
    @objc optional func didChangeNotificationSwitchButton(isOn: Bool)
}
