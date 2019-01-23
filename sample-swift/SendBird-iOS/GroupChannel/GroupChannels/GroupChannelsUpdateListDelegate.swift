//
//  GroupChannelsUpdateListDelegate.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/15/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import Foundation
import SendBirdSDK

@objc protocol GroupChannelsUpdateListDelegate: NSObjectProtocol {
    @objc optional func updateGroupChannelList()
}
