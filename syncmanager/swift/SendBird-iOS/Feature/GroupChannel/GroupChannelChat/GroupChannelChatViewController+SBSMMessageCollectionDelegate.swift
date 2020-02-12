//
//  GroupChannelChatViewController+SBSMMessageCollectionDelegate.swift
//  SendBird-iOS
//
//  Created by Harry Kim on 2019/12/19.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import SendBirdSyncManager

extension GroupChannelChatViewController: SBSMMessageCollectionDelegate {

    func collection(_ collection: SBSMMessageCollection, didRemove channel: SBDGroupChannel) {
        // TODO: Close View.
    }
    
    func collection(_ collection: SBSMMessageCollection, didUpdate channel: SBDGroupChannel) {
        // TODO: Update channel.
    }
    
    func collection(_ collection: SBSMMessageCollection, didReceiveNewMessage message: SBDBaseMessage) {
        // TODO: Show something to notify the real-time message has been arrived!
    }
    
    func collection(_ collection: SBSMMessageCollection, didReceive action: SBSMMessageEventAction, pendingMessages: [SBDBaseMessage]) {
        switch action {
        case .insert:
            self.insertRows(messages: pendingMessages)
            
        case .update:
            self.updateMessages(messages: pendingMessages)
            
        case .remove:
            self.removeMessages(messages: pendingMessages)
            
        case .clear:
            print("")
            
        case .none:
            print("")
            
        default:
            print("")

        }
    }
    
    func collection(_ collection: SBSMMessageCollection, didReceive action: SBSMMessageEventAction, succeededMessages: [SBDBaseMessage]) {
        switch action {
        case .insert:
            self.channel?.markAsRead()
            self.delegate?.updateGroupChannelList?()
            self.insertRows(messages: succeededMessages)
            
        case .update:
            self.updateMessages(messages: succeededMessages)
            
        case .remove:
            self.removeMessages(messages: succeededMessages)
            
        case .clear:
            print("")
            
        case .none:
            print("")
            
        default:
            print("")
        }
    }
    
    func collection(_ collection: SBSMMessageCollection, didReceive action: SBSMMessageEventAction, failedMessages: [SBDBaseMessage], reason: SBSMFailedMessageEventActionReason) {
        switch action {
        case .insert:
            self.insertRows(messages: failedMessages)
            
        case .update:
            self.updateMessages(messages: failedMessages)
            
        case .remove:
            self.removeMessages(messages: failedMessages)
            
        case .clear:
            print("")
            
        case .none:
            print("")
            
        default:
            print("")
        }
    }
}
