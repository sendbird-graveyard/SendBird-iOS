//
//  OpenChannelMessageTableViewCellDelegate.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/18/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import Foundation
import SendBirdSDK

@objc protocol OpenChannelMessageTableViewCellDelegate: NSObjectProtocol {
    @objc optional func didClickUserProfile(_ user: SBDUser)
    @objc optional func didLongClickUserProfile(_ user: SBDUser)
    
    @objc optional func didClickResendUserMessageButton(_ message: SBDUserMessage)
    @objc optional func didClickResendImageFileMessageButton(_ message: SBDFileMessage)
    @objc optional func didClickResendGeneralFileMessageButton(_ message: SBDFileMessage)
    
    @objc optional func didClickImageVideoFileMessage(_ message: SBDFileMessage)
    @objc optional func didClickGeneralFileMessage(_ message: SBDFileMessage)
    
    @objc optional func didLongClickAdminMessage(_ message: SBDAdminMessage)
    @objc optional func didLongClickUserMessage(_ message: SBDUserMessage)
    @objc optional func didLongClickImageVideoFileMessage(_ message: SBDFileMessage)
    @objc optional func didLongClickGeneralFileMessage(_ message: SBDFileMessage)
}
