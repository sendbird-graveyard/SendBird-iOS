//
//  GroupChannelChatViewController+GroupChannelMessageTableViewCellDelegate.swift
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
import Kingfisher
import NYTPhotoViewer

extension GroupChannelChatViewController: MessageCellDelegate {
    
    // MARK - MessageCellDelegate
    func didLongClickAdminMessage(_ message: SBDAdminMessage) {
        logClickEvent(by: message)
    }
    
    func didLongClickUserMessage(_ message: SBDUserMessage) {
        logClickEvent(by: message)
    }
    
    func didLongClickGeneralFileMessage(_ message: SBDFileMessage) {
        logClickEvent(by: message)
    }
    
    func didLongClickImageVideoFileMessage(_ message: SBDFileMessage) {
        logClickEvent(by: message)
    }
    
    func didClickVideoFileMessage(_ message: SBDFileMessage) {
        self.playMedia(message)
    }
    
    func didClickAudioFileMessage(_ message: SBDFileMessage) {
        self.playMedia(message)
    }
    
    func didClickGeneralFileMessage(_ message: SBDFileMessage) {
        guard let url = URL(string: message.url) else {
            AlertControl.show(parent: self, title: "Error", message: "We do not support this file!", actionMessage: "Close")
            return
        }
        
        let viewController = WebViewController()
        viewController.url = url
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
     
    func didClickResendUserMessage(_ message: SBDUserMessage) {
        self.channel?.resendUserMessage(with: message, completionHandler: self.setSent)
    }
    
    func didLongClickUserProfile(_ user: SBDUser) {
        guard let currentUser = SBDMain.getCurrentUser() else { return }
        if user.userId == currentUser.userId { return }
        
        AlertControl.show(parent: self,
                          title: user.nickname ?? "",
                          message: nil,
                          style: .actionSheet,
                          actionMessage: "Block user")
        { _ in
            SBDMain.blockUser(user) { blockedUser, error in
            }
        }
        
    }
     
    func didClickImageVideoFileMessage(_ message: SBDFileMessage) {

        guard let url = URL(string: message.url) else { return }
        switch message.fileType {
        case .image:
            UIImageView().kf.setImage(with: url) { result in
                switch result {
                case .success(let imageResult):
                    let viewer = PhotoViewer()
                    viewer.image = imageResult.image
                    let vc = CustomPhotosViewController(photos: [viewer])
                    vc.hero.isEnabled = true
                    vc.view?.hero.id = "media"
                    
                    // let photoVC = vc.pageViewController?.viewControllers?.first as? NYTPhotoViewController
                    // photoVC?.scalingImageView.imageView.hero.id = "media"
                    
                    self.present(vc, animated: true)
                default:
                    break
                }
            }

        case .video:
            let player = AVPlayer(url: url)
        
            let playerVC = AVPlayerViewController()
            playerVC.hero.isEnabled = true
            playerVC.view.hero.id = "media"
            playerVC.player = player
            self.present(playerVC, animated: true) {
                player.play()
            }
        default:
            assertionFailure("")
        }
    }
    
    func didClickUserProfile(_ user: SBDUser) {
        DispatchQueue.main.async {
            let vc = UserProfileViewController.initiate()
            vc.user = user
            guard let navigationController = self.navigationController else { return }
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    func didClickResendImageVideoFileMessage(_ message: SBDFileMessage) {
        self.resendFileMessage(with: message)
    }
    
    func didClickResendAudioGeneralFileMessage(_ message: SBDFileMessage) {
        self.resendFileMessage(with: message)
    }
}

extension GroupChannelChatViewController {
    func deleteChannel() {
        
    }
}
extension GroupChannelChatViewController {
    func logClickEvent(by message: SBDBaseMessage) {
        // haptic
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in self.deleteMessage(message) }
        guard let currentUser = SBDMain.getCurrentUser() else { return }

        switch message {
            
        case let message as SBDAdminMessage:
            AlertControl.show(parent: self, title: message.message ?? "", style: .actionSheet, actionMessage: "Copy message") { _ in
                UIPasteboard.general.string = message.message
                self.showToast("Copied")
            }
            
        case let message as SBDUserMessage:
            
            let copyAction = UIAlertAction(title: "Copy message", style: .default) { action in
                UIPasteboard.general.string = message.message
                self.showToast("Copied")
            }
            
            let isCurrentUser = message.sender?.userId == currentUser.userId
            let actions: [UIAlertAction] = isCurrentUser ? [copyAction, deleteAction, .cancelAction] : [copyAction, .cancelAction]
            
            AlertControl.show(parent: self, actions: actions, title: message.message, style: .actionSheet)
            
        case let message as SBDFileMessage:
            
            let isMedia = message.fileType == .image || message.fileType == .video
            let title = isMedia ? message.fileType.string : "General file"
            
            let saveAction = UIAlertAction(title: "Save File", style: .default) { action in
                guard let url = URL(string: message.url) else { return }
                DownloadControl.download(url: url, filename: message.name, mimeType: message.type, addToMediaLibrary: false)
            }
            
            let isCurrentUser = message.sender?.userId == currentUser.userId
            let actions: [UIAlertAction] = isCurrentUser ? [saveAction, deleteAction, .cancelAction] : [saveAction, .cancelAction]
            
            AlertControl.show(parent: self, actions: actions, title: title, style: .actionSheet)
            
        default:
            fatalError()
        }
    }
    
    func deleteMessage(_ message: SBDBaseMessage) {
        AlertControl.show(parent: self, title: "Are you sure you want to delete this message?", message: nil, style: .actionSheet, actionMessage: "Yes. Delete the message") { _ in
            self.channel?.delete(message) { error in
                if let error = error {
                    AlertControl.showError(parent: self, error: error)
                    return
                }
                                
                self.collection?.deleteMessage(message)
            }
        }
    }
}
