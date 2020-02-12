//
//  GroupChannelChatViewController+UITableViews.swift
//  SendBird-iOS
//
//  Created by sw.kim on 2019/11/28.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import SendBirdSyncManager
import RSKImageCropper
import Photos
import AVKit
import MobileCoreServices 
import FLAnimatedImage
import Kingfisher

// MARK: - UITableViewDataSource & UITableViewDelegate
extension GroupChannelChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            self.loadPreviousMessages()
        }
 
        guard self.messageControl.models.count > indexPath.row else {
            return UITableViewCell()
        }
        
        let model = self.messageControl.updatedModel(index: indexPath.row)

        guard
            let user = SBDMain.getCurrentUser(),
            let cellIdentifier = model.cellIdentifier(currentUser: user),
            let cell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier),
            let messageCell = cell as? MessageCell
            else { assertionFailure(); return UITableViewCell() }
        
        if model.message.requestState() != .pending {
            messageCell.delegate = self
        }
        
        messageCell.channel = self.channel
        messageCell.configure(with: model)
        
        messageCell.hero.isEnabled = false
        
        return messageCell
 
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.messageControl.models.count
        return count
    }
     
}
