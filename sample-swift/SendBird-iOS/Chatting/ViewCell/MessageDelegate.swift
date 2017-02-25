//
//  MessageDelegate.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/6/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import Foundation
import UIKit
import SendBirdSDK

protocol MessageDelegate: class {
    func clickProfileImage(viewCell: UITableViewCell, user: SBDUser)
    func clickMessage(view: UIView, message: SBDBaseMessage)
    func clickResend(view: UIView, message: SBDBaseMessage)
    func clickDelete(view: UIView, message: SBDBaseMessage)
}
