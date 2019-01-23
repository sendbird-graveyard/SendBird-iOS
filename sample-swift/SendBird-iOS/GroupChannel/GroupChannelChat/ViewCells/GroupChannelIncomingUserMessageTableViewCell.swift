//
//  GroupChannelIncomingUserMessageTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 11/6/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class GroupChannelIncomingUserMessageTableViewCell: UITableViewCell {
    static let kDateSeperatorContainerViewTopMargin: CGFloat = 3.0
    static let kDateSeperatorContainerViewHeight: CGFloat = 65.0
    static let kNicknameContainerViewTopMargin: CGFloat = 3.0
    static let kMessageContainerViewTopMarginNormal: CGFloat = 6.0
    static let kMessageContainerViewTopMarginNoNickname: CGFloat = 3.0
    static let kMessageContainerViewBottomMarginNormal: CGFloat = 14.0
    
    var msg: SBDUserMessage?
    
    @IBOutlet weak var dateSeperatorContainerView: UIView!
    @IBOutlet weak var dateSeperatorLabel: UILabel!
    @IBOutlet weak var profileContainerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var textMessageLabel: UILabel!
    @IBOutlet weak var messageDateLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var messageStatusContainerView: UIView!
    @IBOutlet weak var messageContainerView: UIView!
    
    @IBOutlet weak var dateSeperatorContainerViewTopMargin: NSLayoutConstraint!
    @IBOutlet weak var dateSeperatorContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var nicknameContainerViewTopMargin: NSLayoutConstraint!
    @IBOutlet weak var messageStatusContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var messageContainerViewTopMargin: NSLayoutConstraint!
    @IBOutlet weak var messageContainerViewBottomMargin: NSLayoutConstraint!
    
    weak var delegate: GroupChannelMessageTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setMessages(currMessage: SBDUserMessage, prevMessage: SBDBaseMessage?, nextMessage: SBDBaseMessage?) {
        var hideDateSeperator = false
        var hideProfileImage = false
        var hideNickname = false
        
        let longClickMessageContainerGesture = UILongPressGestureRecognizer(target: self, action: #selector(GroupChannelIncomingUserMessageTableViewCell.longClickUserMessage(_:)))
        self.messageContainerView.addGestureRecognizer(longClickMessageContainerGesture)
        
        let longClickProfileGesture = UILongPressGestureRecognizer(target: self, action: #selector(GroupChannelIncomingUserMessageTableViewCell.longClickProfile(_:)))
        self.profileContainerView.addGestureRecognizer(longClickProfileGesture)
        
        let clickProfileGesture = UITapGestureRecognizer(target: self, action: #selector(GroupChannelIncomingUserMessageTableViewCell.clickProfile(_:)))
        self.profileContainerView.addGestureRecognizer(clickProfileGesture)
        
        var prevMessageSender: SBDUser?
        var nextMessageSender: SBDUser?
        self.msg = currMessage
        guard let message = self.msg else { return }
        self.textMessageLabel.text = message.message
        
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
                prevMessageSender = (nextMessage as! SBDFileMessage).sender
            }
        }
        
        if prevMessage != nil && Utils.checkDayChangeDayBetweenOldTimestamp(oldTimestamp: (prevMessage?.createdAt)!, newTimestamp: message.createdAt) {
            hideDateSeperator = false
        }
        else {
            hideDateSeperator = true
        }
        
        if prevMessageSender != nil && prevMessageSender?.userId == message.sender?.userId {
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
        
        if nextMessageSender != nil && nextMessageSender?.userId == message.sender?.userId {
            if Utils.checkDayChangeDayBetweenOldTimestamp(oldTimestamp: message.createdAt, newTimestamp: (nextMessage?.createdAt)!) {
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
            self.dateSeperatorLabel.text = Utils.getDateStringForDateSeperatorFromTimestamp(message.createdAt)
            self.dateSeperatorContainerViewHeight.constant = GroupChannelIncomingUserMessageTableViewCell.kDateSeperatorContainerViewHeight
            self.dateSeperatorContainerViewTopMargin.constant = GroupChannelIncomingUserMessageTableViewCell.kDateSeperatorContainerViewTopMargin
            self.nicknameContainerViewTopMargin.constant = GroupChannelIncomingUserMessageTableViewCell.kNicknameContainerViewTopMargin
        }
        
        if hideNickname {
            self.nicknameLabel.text = ""
            self.nicknameContainerViewTopMargin.constant = 0
            self.messageContainerViewTopMargin.constant = GroupChannelIncomingUserMessageTableViewCell.kMessageContainerViewTopMarginNoNickname
        }
        else {
            if message.sender!.nickname?.count == 0 {
                self.nicknameLabel.text = " "
            }
            else {
                self.nicknameLabel.text = message.sender?.nickname
            }
            
            self.nicknameContainerViewTopMargin.constant = GroupChannelIncomingUserMessageTableViewCell.kNicknameContainerViewTopMargin
            self.messageContainerViewTopMargin.constant = GroupChannelIncomingUserMessageTableViewCell.kMessageContainerViewTopMarginNormal
        }
        
        if hideProfileImage {
            self.messageDateLabel.text = ""
            self.profileContainerView.isHidden = true
            self.messageStatusContainerView.isHidden = true
            self.messageContainerViewBottomMargin.constant = 0
        }
        else {
            self.messageDateLabel.text = Utils.getMessageDateStringFromTimestamp(message.createdAt)
            self.profileContainerView.isHidden = false
            self.messageStatusContainerView.isHidden = false
            self.messageContainerViewBottomMargin.constant = GroupChannelIncomingUserMessageTableViewCell.kMessageContainerViewBottomMarginNormal
        }
    }
    
    func getMessage() -> SBDUserMessage? {
        return self.msg
    }
    
    @objc func longClickUserMessage(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            guard let delegate = self.delegate else { return }
            if delegate.responds(to: #selector(GroupChannelMessageTableViewCellDelegate.didLongClickUserMessage)) {
                delegate.didLongClickUserMessage!(self.msg!)
            }
        }
    }
    
    @objc func longClickProfile(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            guard let delegate = self.delegate else { return }
            if delegate.responds(to: #selector(GroupChannelMessageTableViewCellDelegate.didLongClickUserProfile)) {
                delegate.didLongClickUserProfile!((self.msg?.sender)!)
            }
        }
    }
    
    @objc func clickProfile(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == .began {
            guard let delegate = self.delegate else { return }
            if delegate.responds(to: #selector(GroupChannelMessageTableViewCellDelegate.didClickUserProfile)) {
                delegate.didClickUserProfile!((self.msg?.sender)!)
            }
        }
    }
}
