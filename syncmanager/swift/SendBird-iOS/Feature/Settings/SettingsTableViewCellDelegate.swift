//
//  SettingsTableViewCellDelegate.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/17/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import Foundation

protocol SettingsTableViewCellDelegate: NSObjectProtocol {
    func didChangeSwitchButton(isOn: Bool, identifier: String)
}
