//
//  OpenChanannelChatDelegate.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/16/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import Foundation
import SendBirdSDK

@objc protocol OpenChanannelChatDelegate: NSObjectProtocol {
    @objc optional func didUpdateOpenChannel()
}
