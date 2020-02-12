//
//  GroupChannelChatViewController+SBDChannelDelegate.swift
//  SendBird-iOS
//
//  Created by sw.kim on 2019/11/28.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import RSKImageCropper
import Photos
import AVKit
import MobileCoreServices 
import FLAnimatedImage

// MARK: - SBDChannelDelegate
// TODO: Remove
extension GroupChannelChatViewController: SBDChannelDelegate {
    func channelDidUpdateReadReceipt(_ sender: SBDGroupChannel) {
        guard sender == self.channel else { return }
        DispatchQueue.main.async {
            UIView.setAnimationsEnabled(false)
            self.tableView.reloadData()
            self.tableView.setContentOffset(self.tableView.contentOffset, animated: false)
            UIView.setAnimationsEnabled(true)
        }
    }
    
    func channelDidUpdateTypingStatus(_ sender: SBDGroupChannel) {
        let typingIndicatorText = Utils.buildTypingIndicatorLabel(channel: sender)
        if self.typingIndicatorTimer != nil {
            self.typingIndicatorTimer!.invalidate()
            self.typingIndicatorTimer = nil
        }
        self.typingIndicatorTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(GroupChannelChatViewController.hideTypingIndicator(_:)), userInfo: nil, repeats: false)
        let hasText = typingIndicatorText.count > 0
        DispatchQueue.main.async {
            self.typingIndicatorContainerView.isHidden = !hasText
            self.typingIndicatorLabel.text = typingIndicatorText
            self.messageTableViewBottomMargin.constant = hasText ? self.typingIndicatorContainerViewHeight.constant : 0
            self.view.updateConstraints()
            self.view.layoutIfNeeded()
        }
    }
}
