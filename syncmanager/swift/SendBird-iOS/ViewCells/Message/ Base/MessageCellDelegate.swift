//
//  MessageCellDelegate.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 11/29/19.
//  Copyright © 2018 SendBird. All rights reserved.
//

import Foundation
import SendBirdSDK

@objc protocol MessageCellDelegate: NSObjectProtocol {
    @objc optional func didClickResendUserMessage(_ message: SBDUserMessage);
    @objc optional func didClickResendImageVideoFileMessage(_ message: SBDFileMessage);
    @objc optional func didClickResendAudioGeneralFileMessage(_ message: SBDFileMessage);
    @objc optional func didLongClickAdminMessage(_ message: SBDAdminMessage);
    @objc optional func didLongClickUserMessage(_ message: SBDUserMessage);
    @objc optional func didLongClickUserProfile(_ user: SBDUser);
    @objc optional func didClickImageVideoFileMessage(_ message: SBDFileMessage);
    @objc optional func didLongClickImageVideoFileMessage(_ message: SBDFileMessage);
    @objc optional func didLongClickGeneralFileMessage(_ message: SBDFileMessage);
    @objc optional func didClickAudioFileMessage(_ message: SBDFileMessage);
    @objc optional func didClickVideoFileMessage(_ message: SBDFileMessage);
    @objc optional func didClickUserProfile(_ user: SBDUser);
    @objc optional func didClickGeneralFileMessage(_ message: SBDFileMessage);
}
