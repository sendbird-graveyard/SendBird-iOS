//
//  GroupChannelsViewController+SBDChannelDelegate.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 2019/12/12.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

extension GroupChannelsViewController: SBDChannelDelegate {
    func channelDidUpdateTypingStatus(_ sender: SBDGroupChannel) {
        let timer = Timer.scheduledTimer(timeInterval: 10, target: self,
                                         selector: #selector(GroupChannelsViewController.typingIndicatorTimeout(_ :)),
                                         userInfo: sender.channelUrl, repeats: false)
        
        self.trypingIndicatorTimer[sender.channelUrl]?.invalidate()
        self.trypingIndicatorTimer[sender.channelUrl] = timer
        
        self.reloadChannel(sender)

    }
    
    func channel(_ sender: SBDGroupChannel, userDidJoin user: SBDUser) {
        self.reloadChannel(sender)
    }
    
    func channel(_ sender: SBDGroupChannel, userDidLeave user: SBDUser) {
        self.reloadChannel(sender)
    }
    
    func channelWasChanged(_ sender: SBDBaseChannel) {
        guard let channel = sender as? SBDGroupChannel
            else { assertionFailure("Channel must group channel"); return }
        self.reloadChannel(channel)
    }
    
    func channel(_ sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {
        guard let channel = sender as? SBDGroupChannel
            else { assertionFailure("Channel must group channel"); return }
        self.reloadChannel(channel)
        self.updateTotalUnreadMessageCountBadge()
    }
}
