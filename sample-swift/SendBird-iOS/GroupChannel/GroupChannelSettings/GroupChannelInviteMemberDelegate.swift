//
//  GroupChannelInviteMemberDelegate.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 11/16/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import Foundation

@objc protocol GroupChannelInviteMemberDelegate: NSObjectProtocol {
    @objc optional func didInviteMembers()
}
