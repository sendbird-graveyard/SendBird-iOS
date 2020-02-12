//
//  GroupChannelChatViewController+Keyboard.swift
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

// MARK: - Keyboard
extension GroupChannelChatViewController {
    func determineScrollLock() {
        guard
            self.messageControl.models.count > 0,
            let indexPaths = self.tableView.indexPathsForVisibleRows,
            let lastVisibleCellIndexPath = indexPaths.last
            else { return }
        
        let lastVisibleRow = lastVisibleCellIndexPath.row
        if lastVisibleRow < self.messageControl.models.count - 1 {
            self.scrollLock = true
        }
        else {
            self.scrollLock = false
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        self.determineScrollLock()
        
        self.keyboardShown = true
       
        let (height, duration, _) = Utils.getKeyboardAnimationOptions(notification: notification)
        
        self.keyboardHeight = height ?? 0
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: duration ?? 0, delay: 0, options: .curveEaseOut, animations: {
                self.inputMessageInnerContainerViewBottomMargin.constant = self.keyboardHeight - self.view.safeAreaInsets.bottom
                self.view.layoutIfNeeded()
            }, completion: nil)
            
            self.keyboardShown = true
        }
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        DispatchQueue.main.async {
            self.scrollToBottom(animated: false, force: false)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.determineScrollLock()
        
        self.keyboardShown = false
        self.keyboardHeight = 0
        
        let (_, duration, _) = Utils.getKeyboardAnimationOptions(notification: notification)
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: duration ?? 0, delay: 0, options: .curveEaseOut, animations: {
                self.inputMessageInnerContainerViewBottomMargin.constant = 0
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        DispatchQueue.main.async {
            self.scrollToBottom(animated: false, force: false)
        }
    }
    
    @objc func hideKeyboard(recognizer: UITapGestureRecognizer) {
        guard keyboardShown == true else { return }
        
        if recognizer.state == .ended {
            self.view.endEditing(true)
        }
    }
    
    func hideKeyboardWhenFastScrolling() {
        guard self.keyboardShown else { return }
        
        self.view.endEditing(true)
        self.scrollToBottom(animated: false, force: false)
    }
}
