//
//  OpenChannelCoverImageNameSettingDelegate.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 11/1/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import Foundation

@objc protocol OpenChannelCoverImageNameSettingDelegate: NSObjectProtocol {
    @objc optional func didUpdateOpenChannel()
}
