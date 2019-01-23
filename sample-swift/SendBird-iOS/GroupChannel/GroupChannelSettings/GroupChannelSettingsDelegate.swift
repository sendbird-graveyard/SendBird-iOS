//
//  GroupChannelSettingsDelegate.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 11/2/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import Foundation

@objc protocol GroupChannelSettingsDelegate: NSObjectProtocol {
    @objc optional func didLeaveChannel();
}
