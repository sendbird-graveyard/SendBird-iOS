//
//  GroupChannelIncomingImageVideoFileMessageTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 11/6/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import FLAnimatedImage

class GroupChannelIncomingImageVideoFileMessageTableViewCell: UITableViewCell {
    weak var delegate: GroupChannelMessageTableViewCellDelegate?
    var imageHash: Int = 0
    
    @IBOutlet weak var dateSeperatorContainerView: UIView!
    @IBOutlet weak var dateSeperatorLabel: UILabel!
    @IBOutlet weak var profileContainerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageContainerView: UIView!
    @IBOutlet weak var imageFileMessageImageView: FLAnimatedImageView!
    @IBOutlet weak var messageDateLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var messageStatusContainerView: UIView!
    @IBOutlet weak var videoPlayIconImageView: UIImageView!
    @IBOutlet weak var imageMessagePlaceholderImageView: UIImageView!
    @IBOutlet weak var videoMessagePlaceholderImageView: UIImageView!
    
    @IBOutlet weak var dateSeperatorContainerViewTopMargin: NSLayoutConstraint!
    @IBOutlet weak var dateSeperatorContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var nicknameContainerViewTopMargin: NSLayoutConstraint!
    @IBOutlet weak var messageStatusContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var messageContainerViewTopMargin: NSLayoutConstraint!
    @IBOutlet weak var messageContainerViewBottomMargin: NSLayoutConstraint!
    
    static let kDateSeperatorContainerViewTopMargin: CGFloat = 3.0
    static let kDateSeperatorContainerViewHeight: CGFloat = 65.0
    static let kNicknameContainerViewTopMargin: CGFloat = 3.0
    static let kMessageContainerViewTopMarginNormal: CGFloat = 6.0
    static let kMessageContainerViewTopMarginNoNickname: CGFloat = 3.0
    static let kMessageContainerViewBottomMarginNormal: CGFloat = 14.0
    
    private var msg: SBDFileMessage?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setMessage(currMessage: SBDFileMessage, prevMessage: SBDBaseMessage?, nextMessage: SBDBaseMessage?) {
        var hideDateSeperator = false
        var hideProfileImage = false
        var hideNickname = false
        
        let clickMessageContainteGesture = UITapGestureRecognizer(target: self, action: #selector(GroupChannelIncomingImageVideoFileMessageTableViewCell.clickImageVideoFileMessage(_:)))
        self.messageContainerView.addGestureRecognizer(clickMessageContainteGesture)
        
        let longClickMessageContainerGesture = UILongPressGestureRecognizer(target: self, action: #selector(GroupChannelIncomingImageVideoFileMessageTableViewCell.longClickImageVideoFileMessage(_:)))
        self.messageContainerView.addGestureRecognizer(longClickMessageContainerGesture)
        
        let longClickProfileGesture = UILongPressGestureRecognizer(target: self, action: #selector(GroupChannelIncomingImageVideoFileMessageTableViewCell.longClickProfile(_:)))
        self.profileContainerView.addGestureRecognizer(longClickProfileGesture)
        
        let clickProfileGesture = UITapGestureRecognizer(target: self, action: #selector(GroupChannelIncomingImageVideoFileMessageTableViewCell.clickProfile))
        self.profileContainerView.addGestureRecognizer(clickProfileGesture)
        
        var prevMessageSender: SBDUser?
        var nextMessageSender: SBDUser?
        self.msg = currMessage
        
        if prevMessage != nil {
            if prevMessage is SBDUserMessage {
                prevMessageSender = (prevMessage as! SBDUserMessage).sender
            }
            else if prevMessage is SBDFileMessage {
                prevMessageSender = (prevMessage as! SBDFileMessage).sender
            }
        }
        
        if nextMessage != nil {
            if nextMessage is SBDUserMessage {
                nextMessageSender = (nextMessage as! SBDUserMessage).sender
            }
            else if nextMessage is SBDFileMessage {
                nextMessageSender = (nextMessage as! SBDFileMessage).sender
            }
        }
        
        if prevMessage != nil && Utils.checkDayChangeDayBetweenOldTimestamp(oldTimestamp: (prevMessage?.createdAt)!, newTimestamp: (self.msg?.createdAt)!) {
            hideDateSeperator = false
        }
        else {
            hideDateSeperator = true
        }
        
        if prevMessageSender != nil && prevMessageSender?.userId == self.msg!.sender?.userId {
            if hideDateSeperator {
                hideNickname = true
            }
            else {
                hideNickname = false
            }
        }
        else {
            hideNickname = false
        }
        
        if nextMessageSender != nil && nextMessageSender?.userId == self.msg!.sender?.userId {
            if Utils.checkDayChangeDayBetweenOldTimestamp(oldTimestamp: (self.msg?.createdAt)!, newTimestamp: (nextMessage?.createdAt)!) {
                hideProfileImage = false
            }
            else {
                hideProfileImage = true
            }
        }
        else {
            hideProfileImage = false
        }
        
        if hideDateSeperator {
            self.dateSeperatorContainerView.isHidden = true
            self.dateSeperatorLabel.text = ""
            self.dateSeperatorContainerViewHeight.constant = 0
            self.dateSeperatorContainerViewTopMargin.constant = 0
            self.nicknameContainerViewTopMargin.constant = 0
        }
        else {
            self.dateSeperatorContainerView.isHidden = false
            self.dateSeperatorLabel.text = Utils.getDateStringForDateSeperatorFromTimestamp((self.msg?.createdAt)!)
            self.dateSeperatorContainerViewHeight.constant = GroupChannelIncomingImageVideoFileMessageTableViewCell.kDateSeperatorContainerViewHeight
            self.dateSeperatorContainerViewTopMargin.constant = GroupChannelIncomingImageVideoFileMessageTableViewCell.kDateSeperatorContainerViewTopMargin
            self.nicknameContainerViewTopMargin.constant = GroupChannelIncomingImageVideoFileMessageTableViewCell.kNicknameContainerViewTopMargin
        }
        
        if hideNickname {
            self.nicknameLabel.text = ""
            
            self.nicknameContainerViewTopMargin.constant = 0
            self.messageContainerViewTopMargin.constant = GroupChannelIncomingImageVideoFileMessageTableViewCell.kMessageContainerViewTopMarginNoNickname
        }
        else {
            if self.msg!.sender!.nickname!.count == 0 {
                self.nicknameLabel.text = " "
            }
            else {
                self.nicknameLabel.text = self.msg!.sender!.nickname
            }
            
            self.nicknameContainerViewTopMargin.constant = GroupChannelIncomingImageVideoFileMessageTableViewCell.kNicknameContainerViewTopMargin
            self.messageContainerViewTopMargin.constant = GroupChannelIncomingImageVideoFileMessageTableViewCell.kMessageContainerViewTopMarginNormal
        }
        
        if hideProfileImage {
            self.messageDateLabel.text = ""
            
            self.profileContainerView.isHidden = true
            self.messageStatusContainerView.isHidden = true
            self.messageContainerViewBottomMargin.constant = 0
        }
        else {
            self.messageDateLabel.text = Utils.getMessageDateStringFromTimestamp(self.msg!.createdAt)
            
            self.profileContainerView.isHidden = false
            self.messageStatusContainerView.isHidden = false
            self.messageContainerViewBottomMargin.constant = GroupChannelIncomingImageVideoFileMessageTableViewCell.kMessageContainerViewBottomMarginNormal
        }
    }
    
    func getMessage() -> SBDFileMessage? {
        return self.msg
    }
    
    func hideAllPlaceholders() {
        self.videoPlayIconImageView.isHidden = true
        self.imageMessagePlaceholderImageView.isHidden = true
        self.videoMessagePlaceholderImageView.isHidden = true
    }
    
    @objc func clickImageVideoFileMessage(_ recognizer: UITapGestureRecognizer) {
        if let delegate = self.delegate {
            if delegate.responds(to: #selector(GroupChannelMessageTableViewCellDelegate.didClickImageVideoFileMessage(_:))) {
                delegate.didClickImageVideoFileMessage!(self.msg!)
            }
        }
    }
    
    @objc func longClickImageVideoFileMessage(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            if let delegate = self.delegate {
                if delegate.responds(to: #selector(GroupChannelMessageTableViewCellDelegate.didLongClickImageVideoFileMessage(_:))) {
                    delegate.didLongClickImageVideoFileMessage!(self.msg!)
                }
            }
        }
    }
    
    @objc func longClickProfile(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            if let delegate = self.delegate {
                if delegate.responds(to: #selector(GroupChannelMessageTableViewCellDelegate.didLongClickUserProfile(_:))) {
                    delegate.didLongClickUserProfile!(self.msg!.sender!)
                }
            }
        }
    }
    
    @objc func clickProfile() {
        if let delegate = self.delegate {
            if delegate.responds(to: #selector(GroupChannelMessageTableViewCellDelegate.didClickUserProfile(_:))) {
                delegate.didClickUserProfile!(self.msg!.sender!)
            }
        }
    }
    
    func setAnimatedImage(_ image: FLAnimatedImage?, hash: Int) {
        if image == nil || hash == 0 {
            self.imageHash = 0
            self.imageFileMessageImageView.animatedImage = nil
        }
        else {
            if self.imageHash == 0 || self.imageHash != hash {
                self.imageFileMessageImageView.image = nil
                self.imageFileMessageImageView.animatedImage = image
                self.imageHash = hash
            }
        }
    }
    
    func setImage(_ image: UIImage?) {
        if image == nil {
            self.imageHash = 0
            self.imageFileMessageImageView.image = nil
        }
        else {
            let newImageHash = image?.jpegData(compressionQuality: 0.5).hashValue
            if self.imageHash == 0 || self.imageHash != newImageHash {
                self.imageFileMessageImageView.animatedImage = nil
                self.imageFileMessageImageView.image = image
                self.imageHash = newImageHash!
            }
        }
    }
}
