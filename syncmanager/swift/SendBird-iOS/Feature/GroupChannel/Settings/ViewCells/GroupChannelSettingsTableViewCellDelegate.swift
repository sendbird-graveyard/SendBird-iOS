//
//  GroupChannelSettingsTableViewCellDelegate.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 11/16/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import Foundation
import SendBirdSDK

protocol GroupChannelSettingsTableViewCellDelegate: NSObjectProtocol {
    func willUpdateChannelNameAndCoverImage()
    func didChangeNotificationSwitchButton(isOn: Bool)
}
