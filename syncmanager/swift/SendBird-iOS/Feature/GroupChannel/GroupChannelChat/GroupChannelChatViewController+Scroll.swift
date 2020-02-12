//
//  GroupChannelChatViewController+Scroll.swift
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

// MARK: - Scroll
extension GroupChannelChatViewController {
    func scrollToBottom(animated: Bool, force: Bool) {
        let rowCount = self.tableView.numberOfRows(inSection: 0)
        guard rowCount > 0 else { return }
        let indexPath = IndexPath(row: rowCount - 1, section: 0)
        if force {
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
        else {
            if !self.scrollLock {
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
            }
        }
    }
    
    func scrollTo(position: Int) {
        if self.messageControl.models.count == 0 {
            return
        }
        
        self.tableView.scrollToRow(at: IndexPath(row: position, section: 0), at: .top, animated: false)
    }
}
