//
//  GroupChannelsViewController+GroupChannelsUpdateListDelegate.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 2019/12/12.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
 
extension GroupChannelsViewController: GroupChannelsUpdateListDelegate {
    func updateGroupChannelList() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        self.updateTotalUnreadMessageCountBadge()
    }
}
